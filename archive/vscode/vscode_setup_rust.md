# [vscode配置Rust环境](/archive/vscode/vscode_setup_rust.md)

vscode的Rust插件和rust-analyzer(以下简称ra)插件会冲突，都支持codelen功能(可执行函数附近会有Run/Debug提示，就像IDEA在main()左边会有个绿色的运行按钮)，建议只用ra插件

## 安装ra插件的三个步骤

1. 安装base-devel和clang等llvm调试工具，才能安装CodeLLDB插件(开启Rust单步调试功能)
2. 获取ra可执行文件 并 修改vscode全局setting.json的ra相关可执行文件路径配置项
3. vscode安装ra插件

*注3: 编译ra源码的补充，看源码的`.cargo/config`文件可知通过`cargo xtask install --server`可以仅编译ra可执行文件，不编译安装ra的vscode插件

## 获取ra可执行文件的N种方法

1. vscode装ra插件时自动去github下载，但是会出现github链接404错误或vscode需要存储github_token等问题
2. 自行去ra的github仓库的release页面下载相应操作系统编译好的二进制可执行文件分发
3. git clone ra源码进行编译
4. sudo pacman -S rust-analyzer
5. rustup component add rust-analyzer-preview

由于ra更新推送速度上 rustup > archlinux源 > manjaro源，建议用第五种方法安装并管理ra的更新

运行rust-analyzer可执行文件的方法

> rustup run nightly rust-analyzer --version

vscode的setting.json中ra相关配置

```json
{ "rust-analyzer.server.path": "~/.rustup/toolchains/nightly-x86_64-unknown-linux-gnu/bin/rust-analyzer" }
```

## 为什么不建议用源码编译的dev版ra插件

dev版也就是nightly版插件要配合vscode的ra插件启用一些配置项才能使用，不太方便，而且dev版ra插件会有报错提示:

> Extension 'matklad.rust-analyzer cannot use PROPOSED API

而且从源码编译ra插件需要nodejs环境

## 为什么不用官方的Rust插件+rls

1. rls官方维护的不勤快，不支持2021年以后的nightly版本，Rust插件需要rustup额外安装rls和rust-analysis两个component
2. 官方的Rust插件近一年都没更新，不像ra插件频繁维护
3. 同时安装Rust和ra插件时，ra插件会提示冲突you must disable one of them

## Rust静态分析工具推荐

通过包管理pacman安装的rustup和rustup.rs的rustup安装脚本的区别在于

1. cargo/rustup的路径在/usr/bin，rust-analyzer的路径还在~/.cargo/bin
2. pacman的rustup不能self update，需要pacman进行更新

cargo install以下几款常用Rust代码静态分析工具

- rust-analyzer
- cargo-all-features(好像是检查unused features，但是运行时报错)
- cargo-udeps(检查未使用的依赖，超赞)
- cargo-audit(检查第三方库所用版本的是否存在已通报的漏洞)
- cargo-outdated(类似vscode_crates插件，但不如crates好用)

## code snippet/completion

idea的code_snippet指的是类似idea输入sout能自动生成`System.out.println!("");`这样的代码模板生成或自动补全

也叫[Save as Live Template](https://www.jetbrains.com/webstorm/guide/tips/save-as-live-template/)

部分我认为很有用的代码补全/代码模板生成

| input | generexprte code | require |
|---| ------ | ---- |
| expr.mexprtch | match expr... | expr is enum |
| expr.if | if expr {... | expr is bool |
| expr.ifl | if let... | (ra only)expr is Option/Result |
| expr.dbg | dbg!(expr) |
| expr.dbgr | dbg!(&expr) |
| p | println!("") | (idea only) |
| pd | eprintln!(" = {:?}", ); |
| pdd | eprintln!(" = {:#?}", ); |
| tmod | #\[cfg(test)] mod tests... |
| tfn | #\[test] fn... |
| "{expr}".logi | log::info!("{}", expr) | (ra only) |

*注: `"".`+logd/logw/panic/format等也是类似"".logi的效果

[参考ra源码](https://github.com/rust-analyzer/rust-analyzer/blob/master/crates/completion/src/lib.rs#L29)

## vscode-ra/idea展开声明宏

vscode光标移到宏上，输入command `expand macro`就能在右侧显示声明宏展开后的代码

idea则是alt+enter的code_action里可以展开宏

无论是idea或vscode都不支持过程宏的展开，过程宏展开只能靠cargo expand

![](rust_analyzer_code_snippet_completion.gif)

## vscode Rust插件推荐

- CodeLLDB: Rust或rust-analyzer依赖插件，用于打断点调试
- rust-analyzer: Rust官方插件的替代品，必装
- crates: 类似cargo-outdated静态分析工具，提示Cargo.toml中哪些第三方库可以更新
- code_spell_checker: typo检查，毕竟参与开源项目时第一个PR也就只能修修typo再慢慢参与更核心部分的修改
- Bookmarks: 类似idea的书签功能，方便读源码时记录关键位置，方便跳转

## ra和intellij-Rust的比较

ra的不足:
- .into()只能跳转到std的into trait,不能像idea那样User::default()跳到相应的类型转行代码(最新的idea into/default 90%都是跳转到标准库，也变得不好使了)

intellij-Rust的不足:
- 不支持rustc源码的静态分析
- 在返回值是复杂的impl范型中(例如warp)，容易误报unresolved reference

## Rust有趣的学习资料

- (入门)[一个内嵌playground的多国语言Rust教程](https://tourofrust.com/00_zh-cn.html)
- (入门)rustlings: rustlings watch可以监控exercises文件夹的变化，一共有多个例如编译报错这样练习题，让你逐个修改源文件进行闯关n
- (较难)[rust-quiz](https://dtolnay.github.io/rust-quiz)
- (较难)cppquiz.org

---

总之Rust的开发环境用 vscode+ra 或 idea_ce(社区版)+Rust插件 这两个方案都不错(配置超简单，功能强，开发者频繁维护/迭代)
