# Cargo相关

[Why do binaries have Cargo.lock in version control, but not libraries?]
(https://doc.rust-lang.org/cargo/faq.html#why-do-binaries-have-cargolock-in-version-control-but-not-libraries)

简单来说作为executable项目需要记录上次成功编译时所有crate依赖的版本信息，而lib项目是被其它项目引用的，各个crate版本信息需要弹性处理不能依赖Cargo.lock文件

## 好用的cargo插件/第三方静态分析工具

### cargo udeps: 检查未使用的依赖(第三方crate)

这个工具比较智能，能

### cargo audit: 检查一些库的漏洞或是否过时

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

Crate:         block-cipher
Version:       0.7.1
Warning:       unmaintained
Title:         crate has been renamed to `cipher`
Date:          2020-10-15
ID:            RUSTSEC-2020-0057
URL:           https://rustsec.org/advisories/RUSTSEC-2020-0057
Dependency tree: 
block-cipher 0.7.1
├── aesni 0.7.0
│   └── aes 0.4.0
│       └── aes-gcm 0.6.0
│           └── cookie 0.14.2
│               └── http-types 2.5.0
│                   ├── tide 0.13.0
│                   │   └── matcher 0.0.1
│                   ├── http-client 6.1.0
│                   │   └── tide 0.13.0
│                   ├── async-sse 4.0.1
│                   │   └── tide 0.13.0
│                   └── async-h1 2.1.2
│                       └── tide 0.13.0
├── aes-soft 0.4.0
│   └── aes 0.4.0
├── aes-gcm 0.6.0
└── aes 0.4.0

Crate:         net2
Version:       0.2.35
Warning:       unmaintained
Title:         `net2` crate has been deprecated; use `socket2` instead
Date:          2020-05-01
ID:            RUSTSEC-2020-0016
URL:           https://rustsec.org/advisories/RUSTSEC-2020-0016
Dependency tree: 
net2 0.2.35
├── miow 0.2.1
...
└── mio 0.6.22

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
warning: 3 allowed warnings found
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