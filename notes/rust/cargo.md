# Cargo相关

[Why do binaries have Cargo.lock in version control, but not libraries?](https://doc.rust-lang.org/cargo/faq.html#why-do-binaries-have-cargolock-in-version-control-but-not-libraries)

简单来说作为executable项目需要记录上次成功编译时所有crate依赖的版本信息，而lib项目是被其它项目引用的，各个crate版本信息需要弹性处理不能依赖Cargo.lock文件

## cargo patch

发现bson库有bug(日期没截断成i64序列化panic),fork一份改了，但是mongodb等等众多库也依赖bson

难道还要fork一份mongodb改掉bson依赖链接？

建议在workspace的Cargo.toml中加上 [patch.crates-io] 这样其它依赖bson的库就会去我fork的repo找bson而非crates.io

## 好用的cargo插件/第三方静态分析工具

- cargo metadata
- cargo udeps: 检查未使用的依赖(第三方crate)
- cargo audit: 检查一些库的漏洞或是否过时

```
$ cargo audit
    Fetching advisory database from `https://github.com/RustSec/advisory-db.git`
      Loaded 145 security advisories (from /Users/wuaoxiang/.cargo/advisory-db)
    Updating crates.io index
    Scanning Cargo.lock for vulnerabilities (246 crate dependencies)
Crate:         futures-util
Version:       0.3.6
Title:         MutexGuard::map can cause a data race in safe code
Date:          2020-10-22
ID:            RUSTSEC-2020-0059
URL:           https://rustsec.org/advisories/RUSTSEC-2020-0059
Solution:      Upgrade to >=0.3.7
Dependency tree: 
futures-util 0.3.6
├── tide 0.13.0
│   └── matcher 0.0.1
├── sqlx-core 0.4.0-beta.1
│   ├── sqlx-macros 0.4.0-beta.1
│   │   └── sqlx 0.4.0-beta.1
│   │       └── matcher 0.0.1
│   └── sqlx 0.4.0-beta.1
├── redis-async 0.6.3
│   └── matcher 0.0.1
├── futures-executor 0.3.6
│   └── futures 0.3.6
│       └── sqlx-macros 0.4.0-beta.1
└── futures 0.3.6

Crate:         stdweb
Version:       0.4.20
Warning:       unmaintained
Title:         stdweb is unmaintained
Date:          2020-05-04
ID:            RUSTSEC-2020-0056
URL:           https://rustsec.org/advisories/RUSTSEC-2020-0056
Dependency tree: 
stdweb 0.4.20
└── time 0.2.22

error: 1 vulnerability found!
warning: 1 allowed warnings found
```

## 内置的部分cargo命令介绍

### cargo fix

虽然能自动修复warning，但是仍需要手动review改动

### cargo tree解决第三方库版本问题

```
root@remote-server:~/app# cargo tree -d | grep md-5
└── md-5 v0.9.0
└── md-5 v0.9.0 (*)
```

### cargo expand(宏展开)

推荐在一个子文件夹内(就一个lib.rs)使用cargo expand，否则将项目的所有rust源文件都展开的话，输出结果长得没法看完

### cargo alias

在项目根目录新建一个文件 .cargo/config 就能实现类似npm run scripts的效果

IDEA运行同一个文件的多个单元测试函数时，默认是多线程的，建议加上--test-threads=1参数避免单元测试之间的数据竞争

```
[alias]
myt = "test -- --test-threads=1 --show-output --color always"
matcher_helper_test = "test --test matcher_helper_test -- --test-threads=1 --show-output --color always"
run_production = "cargo run --release"
```

### 单线程运行单元测试

`cargo test --test filename function_name -- --test-threads=1 --show-output`

---

## cargo文档工具

#### 运行文档中的代码块

在lib.rs中加上`#![doc(html_playground_url = "https://play.rust-lang.org/")]` 即可自动识别代码块，并网页每个代码块的右上角加上Run的按钮

在rust文档中并不需要将\```写成\```才会被识别为Rust代码并可以被执行

即便markdown的code block上加上了no_run，代码块的右上角依然会显示run

推荐用`cargo doc --no-deps`生成不含第三方crate依赖的项目文档

### 注释

Rust中注释可以分为三类: 普通注释、文档注释、module文档注释

普通的//和/**/就不讲了，文档注释下面必须要有语言项目，module注释只能出现于文件头部

#### module文档注释中的两个叹号

文档注释中，两个叹号表示接着上一行内容，会显示在同一行中(同一个p标签中)

//! 第一行

//!! 还是第一行

#### 语言项的文档注释

/// 语言项的单行文档注释

/** */ 语言项的多行文档注释
