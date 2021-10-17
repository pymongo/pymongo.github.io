# [基于编译器插件定制 clippy lint](2021/10/rustc_plugin_custom_lints.md)

在我先前的文章 [custom Rust lint](/2021/06/custom_rust_lint.md) 中分别介绍了 改 clippy 源码和 dylint 库两种添加自定义 lint(静态分析代码检查规则) 的方法

本文基于 Rust 月刊先前文章 [华为 | 如何定制 Rust Clippy](https://rustmagazine.github.io/rust_magazine_2021/chapter_6/custom-clippy.html)

上述文章中提供了改 clippy 源码或 dylint 库的两个开发定制 lint 的方案，

但 dylint 不能跨平台且以动态库形式分发难以使用，改 clippy 源码不方便与官方 lint 同步

基于上述困难，我便有了以下 lint 框架的设计需求:
1. 一定要跨平台，同时支持 windows/mac/linux 等主流操作系统
2. 不要有任何依赖，dylint 依赖 clippy 导致 rust-toolchain 被迫绑定跟 clippy 一样的版本
3. 代码足够简单 50 行足以加新的 Lint，不用任何宏导致 IDE 看宏代码时变成"瞎子"
4. 定制的 lint 工具对 **用户/使用者** 而言要易于使用

首先用 rustc_private 编译器模块将自己 lint 框架的库编译为库(以下简称 lints 库)，然后可通过三种渠道运行

1. rustc plugin 编译器动态库补丁
2. ui_test
3. 改 rust 源码引入 lints 库并编译为 toolchains
4. RUSTC=/path/to/my_rustc cargo check

## RUSTC 环境变量

最简单的定制 lint 的方法，将自己写的 lint 注入到 rustc 中假设将自己修改的 rustc 可执行文件叫 my_rustc

然后运行 `"RUSTC=my_rustc" cargo check` 就能运行自己定制的 lint 的检查了

所以我们将问题简化为 如何改 rustc 源码 + 如何编译 rustc 两个部分(当然这么运行会有问题，后文再展开)

## rustc_driver

如果说 rust 源码路径下的 compiler/rustc/src/main.rs 是最终的编译器二进制文件

那么 rustc_driver 模块就是整个编译器的入口和"大脑"，可以通过 rustc_private feature 引入这些编译器的模块

对比 rustc_driver 源码和 rustc 源码在 `compiler/rustc/src/main.rs` 里面也一行调用 `rustc_driver::main()`

发现只需要一行代码就能让 **自己的代码编译出 rustc 编译器**

```rust
fn main() {
    rustc_driver::RunCompiler::new(&std::env::args().collect::<Vec<_>>(), &mut DefaultCallback).run().unwrap();
}
```

`rustc_driver::RunCompiler.run()` 这就是 rustc 编译器的入口函数，我们将自己可执行文件的参数原封不动的转发给 rustc 就能让"编译器"跑起来

**编译源码的子问题被简化为直接调用 RunCompiler，修改源码子问题转换成改 DefaultCallback 即可**

但自己这样编译出来的 rustc 你发现运行时报错找不到标准库 "can't find crate for `std`" 后文再详细介绍如何解决这个报错

### trait rustc_driver::Callback

无论是官方的 clippy/miri 工具还是第三方的 flowistry(类似 rust-analyzer 的 Rust vscode 插件)或者 c2rust 等静态分析相关的项目

都是通过重写编译器回调 trait 的各个回调钩子方法，注入自己静态分析代码的逻辑

可以参考 flowistry 静态分析的这行代码:

<https://github.com/willcrichton/flowistry/blob/2f0f843d46995367bf20f76b43315a7199bca70d/src/core/analysis.rs#L50>

#### 如何引入 rustc_driver 库

1. rustup component add rustc-dev 然后就可以链接上 `#![feature(rustc_private)] extern crate rustc_driver`
2. crates.io rustc-ap-rustc_driver 这个是 Rust 官方定期将编译器模块同步上传的版本
3. 自己下载 rustc 源码或者通过 github 链接引入

推荐用第一种方法，这样能在本地引入 rustc_driver 动态库解决找不到标准库的问题

### rustc 源码编译

参考官方 RustConf 2021 rustc 的相关演讲，想定制 lint 其实改 rustc 源码就好了

注意 stage0 阶段 0 的 compiler 好像就只有 rustc 一个可执行文件，此时可以用 RUSTC 环境变量替换默认的 rustc

如果想用全新的整套还需要继续通过 stage0 编译产物继续变成出整套 toolchain 进入到 stage1 阶段(产出 cargo, rustfmt 之类的工具)

1. ./x.py setup 选 `b) compiler: Contribute to the compiler itself`
2. ./x.py build
3. rustup toolchain link my_rustc build/x86_64-unknown-linux-gnu/stage1

然后可以在别的项目中 `cargo +my_rustc` 或者 `rustc +my_rustc` 调用自己编译的 rustc

这个 rustc 遗憾的是不兼容 `!#[feature(rustc_private)]` 会跟当前 nightly 的 rustc-dev 组件版本不兼容报错:

> error[E0514]: found crate `rustc_driver` compiled by an incompatible version of rustc

编译 rustc 源码有几大问题:
1. 编译慢，即便在 2021 年单核最强处理器 5900X 超频下全新编译也要 **3 分钟**
2. 不兼容已有 toolchain 的 rustc_private
3. rust 项目源码结构比较复杂，代码分散在几个地方不好理解和修改

## 解决 rustc_driver 编译后找不到标准库

其实只需要在 build.rs 中加入一行，去扩展动态库的搜索路径即可

> println!("cargo:rustc-link-search=/home/w/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu/lib");

build.rs 的 `cargo:rustc-link-search=` 默认库搜索类型是 all 也包含 Rust ABI 的 rlib 格式库文件

但我这样写死的路径没法跨平台，所以还是先获取 rustup 安装路径和 target 信息再拼接路径

```rust
fn main() {
    // e.g. /home/w/.rustup
    let rustup_home = std::env::var("RUSTUP_HOME").unwrap();
    // e.g. nightly-x86_64-unknown-linux-gnu
    let toolchain = std::env::var("RUSTUP_TOOLCHAIN").unwrap();
    // let host = std::env::var("HOST").unwrap();
    let target = std::env::var("TARGET").unwrap();

    // e.g. /home/w/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu/lib
    let path = std::path::Path::new(&rustup_home)
        .join("toolchains")
        .join(toolchain)
        .join("lib")
        .join("rustlib")
        .join(target)
        .join("lib");
    if !path.exists() {
        panic!("{:?} not exist!\nrequire nightly toolchain with rustc-dev component", path);
    }
    println!("cargo:rustc-link-search=all={}", path.to_str().unwrap());
}
```

为了**跨平台**兼容 windows 的路径分隔符 "\\" 我们拼接文件路径是必须要 Path::join 不用字符串拼接 Unix 的分隔符 "/"

同时我们约束下 lint 框架项目的工具链，加入 rust-toolchain.toml

```
[toolchain]
channel = "nightly"
components = ["rustc-dev"]
```

虽然 ldd 可执行文件会提示 librustc_driver 和 libstd not found, 但在 Linux 下暂时可用了

```
[w@ww lints]$ ldd ~/.cargo/bin/lints 
        linux-vdso.so.1 (0x00007ffe27ca6000)
        librustc_driver-e1b628cff3afb6ed.so => not found
        libstd-d6566390077dd5f5.so => not found
```

解决 ldd not found 我有个解决想法是在 lib.rs `#[link(name="libstd-xxx")]` 然后在 main 强制调用里面任意函数实现编译时链接

但是不同电脑的 crate fingerprint 指纹是不一样不能写死

## 50 行代码改造 rustc

例如我想添加一个检测函数名为 foo 的 lint 检查规则

```rust
#![feature(rustc_private)]
extern crate rustc_ast;
extern crate rustc_driver;
extern crate rustc_interface;
extern crate rustc_lint;
extern crate rustc_span;

struct CompilerCallback;
impl rustc_driver::Callbacks for CompilerCallback {
    fn config(&mut self, config: &mut rustc_interface::interface::Config) {
        config.register_lints = Some(Box::new(move |_session, lint_store| {
            lint_store.register_early_pass(|| Box::new(FnNameIsFoo));
        }));
    }
}

struct FnNameIsFoo;
impl FnNameIsFoo {
    const LINT: rustc_lint::Lint = {
        let mut lint = rustc_lint::Lint::default_fields_for_macro();
        lint.name = "fn_name_is_foo";
        lint.default_level = rustc_lint::Level::Warn;
        lint
    };
}

impl rustc_lint::LintPass for FnNameIsFoo {
    fn name(&self) -> &'static str {
        "fn_name_is_foo"
    }
}

impl rustc_lint::EarlyLintPass for FnNameIsFoo {
    fn check_fn(
        &mut self,
        cx: &rustc_lint::EarlyContext<'_>,
        fn_kind: rustc_ast::visit::FnKind<'_>,
        span: rustc_span::Span,
        _: rustc_ast::NodeId,
    ) {
        if let rustc_ast::visit::FnKind::Fn(_, ident, ..) = fn_kind {
            if ident.as_str() == "foo" {
                rustc_lint::LintContext::struct_span_lint(cx, &Self::LINT, span, |diagnostic| {
                    let mut diagnostic = diagnostic.build("foo is a bad name for function");
                    diagnostic.emit();
                });
            }
        }
    }
}

fn main() {
    rustc_driver::RunCompiler::new(&std::env::args().collect::<Vec<_>>(), &mut CompilerCallback).run().unwrap();
}
```

**警告!**由于作者能力有限未能解决的 Bug 以上代码有时候可能不会有任何检测效果，如运行后无反应纯属正常

完整的项目源码在: <https://github.com/pymongo/lints>

可以通过 cargo install --path . 将检查工具安装到电脑上用 RUSTC 环境变量替换成自己编译版本就能定制如下这样的 lint 检查规则

```
warning: foo is a bad name for function
  --> src/lib.rs:21:1
   |
21 | / fn foo() {
22 | |     
23 | | }
   | |_^
   |
   = note: `#[warn(lints::lints::fn_name_is_foo::fnnameisfoo)]` on by default
```

## EarlyLint 和 LateLint 区别

- EarlyLint 指的是 HIR 静态分析的 lint 检查规则
- LateLint  指的是 MIR 静态分析的 lint 检查规则

上述示例中检查函数名放在 HIR 阶段就够了所以用的是 EarlyLint

注意除了 lint 有 early/late 两个概念，泛型和生命周期也有 early/late bound 的概念， C++ 也有 early/late binding 的概念，这三者之间不要搞浑了

---

为了体验下修改 rustc 源码注入自己定制的 lint，以下是我编译 rustc 源码的记录 **与本文无关**

## 编译 rustc 源码的 workflow

> git clone --recursive https://github.com/rust-lang/rust.git

### x.py setup 配置 config.toml

别 `cp config.toml.example config.toml` 默认的配置文件全是空只会编译一个 rustc

根据官方文档 rustc-dev-guide 的 How to Build and Run the Compiler 文章

我先运行 `./x.py setup` 来创建 config.toml 这样能自动切换 git submodule 所需版本

```
$ x.py setup

// ...

Welcome to the Rust project! What do you want to do with x.py?
a) library: Contribute to the standard library
b) compiler: Contribute to the compiler itself
c) codegen: Contribute to the compiler, and also modify LLVM or codegen
d) tools: Contribute to tools which depend on the compiler, but do not modify it directly (e.g. rustdoc, clippy, miri)
e) user: Install Rust from source
Please choose one (a/b/c/d/e): b

// ...

Updating submodule src/tools/rust-analyzer
Submodule path 'src/tools/rust-analyzer': checked out '009e6ceb1ddcd27a9ced3bcb7d0ef823379185a1'
`x.py` will now use the configuration at /home/w/repos/clone_repos/rust/src/bootstrap/defaults/config.compiler.toml

`rustup` failed to link stage 1 build to `stage1` toolchain
To manually link stage 1 build to `stage1` toolchain, run:

            `rustup toolchain link stage1 build/x86_64-unknown-linux-gnu/stage1`

Rust's CI will automatically fail if it doesn't pass `tidy`, the internal tool for ensuring code quality.
If you'd like, x.py can install a git hook for you that will automatically run `tidy --bless` on each commit
to ensure your code is up to par. If you decide later that this behavior is undesirable,
simply delete the `pre-commit` file from .git/hooks.
Would you like to install the git hook?: [y/N] y
Linked `src/etc/pre-commit.sh` to `.git/hooks/pre-commit`

To get started, try one of the following commands:
- `x.py check`
- `x.py build`
- `x.py test`
For more suggestions, see https://rustc-dev-guide.rust-lang.org/building/suggested.html
```

### ./x.py check

非必要，只是在 build 之前预热下检查下错误

可以用 verbose 参数看看 `./x.py check --verbose`

x.py/bootstrap.py 主要用于生成 cargo/rustc 命令再用 Popen 执行

到底会生成怎样的 cargo/rustc 参数

如果没有 stage0 的 cargo/rustc 就会联网根据系统类型去下载 rustc/cargo 的压缩包

联网下载的 rustc/cargo 压缩包的 checksum 在源码的这个文件 src/stage0.json

如果预先编译过一次编译器则会使用本地编译的 stage0 rustc/cargo 去编译 stage0 这是我的个人理解

个人感觉编译过程是:
1. stage0 cargo build bootstrap package, it stage0 cargo not found download from internet
2. bootstrap check env and set some env

rust 项目构建复杂在于这种环环相扣的工程设计，光 rustc-dev-guid 都好几百页

### ./x.py build

1. Building stage0 std // compile ./library/
2. Building stage0 compiler artifacts // compile `./compiler/rustc_*` 因为编译器模块依赖标准库需要先编译标准库
3. Building stage1 std // stage0 std 像是对内的仅用于 stage0 compiler 编译，而 stage1 std 是对外的标准库?
4. Building rustdoc for stage1

在 5900X 处理器下耗时 03:01 (事先跑了遍 check)

自行编译的 rustc 缺点是无法兼容 rustc_private 的动态库版本，此外一切都跟原版 rustc 一样

### 配置 .vscode/settings.json

用 `x.py check` 替代 `cargo check`, 覆盖全局的 rustcSource 配置后

此时用 vscode 打开 rust 源码文件夹终于有 typehint 类型提示和 goto define /find_all_refs 了!

```json
{
    "rust-analyzer.checkOnSave.overrideCommand": [
        "./x.py",
        "check",
        "--json-output"
    ],
    "rust-analyzer.cargo.runBuildScripts": false,
    "rust-analyzer.checkOnSave.command": "check",
    "rust-analyzer.rustcSource": "./Cargo.toml",
    "rust-analyzer.procMacro.enable": false
}
```
