# Rust笔记

## 等待答疑

Rust 1.44更新日志中有这么一段：

[Special cased vec![] to map directly to Vec::new(). This allows vec![] to be able to be used in const contexts.](https://github.com/rust-lang/rust/pull/70632)

PR description中有大量的`IR`缩写，请问IR指的是什么？

### PhantomData

## 概述

### Rust一些优点

- 部署简单
- derive过程宏相比反射机制性能更好
- 没有不能编译的第三方库，Ruby的话一言难尽，例如passgen编译失败、某些依赖llvm编译的库也会失败等等

- Rust的第三方库不依赖Rustc的版本，不像Ruby的httparty，
  在Ruby2.6.1版本上能发www-form的POST请求，
  在Ruby2.5.0版本发送的www-form的POST请求是错误的(非标准格式)

### Rust的缺点

#### 缺点.异步生态不统一

tokio和async_std之争，不支持async triat但Actor里所有通信操作都是异步的需要在同步的函数里写异步的代码块

tokio和actix_rt异步运行时

#### 缺点.不能处理内存分配失败的情况(C语言可以)

#### 缺点.不支持const generic

#### 缺点.过度依赖宏

宏带来可读性差、静态检查等问题，现阶段IDE不支持宏的语法高亮等

## 编译器相关

### inline函数

FFI编程相关，C语言宏在 Rust 中会实现为 #[inline] 函数

## Cargo相关

#### cargo tree解决第三方库版本问题

```
root@remote-server:~/app# cargo tree -d | grep md-5
└── md-5 v0.9.0
└── md-5 v0.9.0 (*)
```

#### cargo expand(宏展开)

推荐在一个子文件夹内(就一个lib.rs)使用cargo expand，否则将项目的所有rust源文件都展开的话，输出结果长得没法看完

#### cargo alias

在项目根目录新建一个文件 .cargo/config 就能实现类似npm run scripts的效果

IDEA运行同一个文件的多个单元测试函数时，默认是多线程的，建议加上--test-threads=1参数避免单元测试之间的数据竞争

```
[alias]
myt = "test -- --test-threads=1 --show-output --color always"
matcher_helper_test = "test --test matcher_helper_test -- --test-threads=1 --show-output --color always"
run_production = "cargo run --release"
```

#### 单线程运行单元测试

`cargo test --test filename function_name -- --test-threads=1 --show-output`

