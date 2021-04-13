# [Rust入门](/2020/04/first_time_learn_rust.md)

ruby的性满足不了实时性很强的需求(股票交易所)，于是尝试下Rust语言曾经在techempower屠榜的actix-web框架

Rust安装类似Haskell要先装ghcup，rustup是强大的Rust工具链管理工具，通过rustup去安装其他工具

## 设置项目repo的rust版本

1. 项目文件夹内放一个`rust-toolchain.toml`
2. `rustup override set nightly-2021-04-08`类似`rbenv local 2.5.1`
3. `rustup run nightly cargo`能暂时调用nighly版本的cargo命令

`rustup override set ni`类似`rbenv local`，设置项目文件夹的Rust版本

通过session连接服务器时(例如Capistrano)可能会找不到cargo命令，需要`source ~/.cargo/env`

## Rust开发环境推荐

### IntellijRust和VScode

- CLion EAP: 只有Clion上的Rust插件支持debugger和profiler，用IDEA或Pycharm CE也ok，毕竟我在工作中极少用断点调试
- vscode: Rust官方维护的vscode插件的codelen(Run/Debug提示)太棒了，就是ra反应有点慢负载高
- evcxr REPL: Rust运行单元测试那么方便(加个#[test]就能让IDE直接运行该方法，像脚本语言一样方便)，REPL意义不大
- jupyter notebook: 意义不大，理由同上

关于vscode可以看我这篇文章: [vscode配置Rust开发环境](/archive/vscode/vscode_setup_rust.md)

以下是evcxr REPL的演示:

![](rust_repl.png)

## 创建一个Rust项目

如果熟悉gcc/g++/make/cmake整套工具链，简单的项目大可不用cargo构建，直接用Makefile和rustc去编译链接

cargo和其它构建工具类似，cargo new --lib ${name}新建一个名为name的lib项目，或者在空文件夹内cargo init也行

### 添加一个第三方库依赖

cargo官方目前还没有像npm add那样的命令，不过可以安装`cargo add`插件，cargo add rand自动将最新版的rand加到toml文件中，很方便

> cargo update: ignore the lock, figure out all the latest version

## 看官方the book学Rust

<i class="fa fa-hashtag"></i>
Rust Book的前两个Demo

Rust book官方给出多个项目Demo让人学习rust，另一个是api手册(基本不怎么看)

这点要改rust点赞，python/ruby官方都没有以项目为基础练手的教学文章

而且Rust book第一个项目是猜数字，比小甲鱼Python猜数字的项目代码量更少，而且还有「非数字输入」的验证与过滤功能

Rust的野心很大，官方的第二个项目竟然是「哲学家进餐问题」，一个项目里把线程、结构体、Interface等概念解释清楚

所以个人感觉学完rust book的前两个Demo足以

```rust
let handles: Vec<_> = philosophers.into_iter().map(|p| {
    // thread::spawn function takes a closure as an argument
    // and executes that closure in a new thread
    thread::spawn(move || {
        // annotation move to indicate that the closure is going to
        // take ownership of the values it’s capturing
        p.eat();
    })
}).collect();
```

## Rust学习资料

- [Rust Book猜数字和哲学家进餐问题的项目式教学](https://doc.rust-lang.org/1.0.0/book/dining-philosophers.html)
- [YouTube上dcode的rust入门教程(42集)](https://www.youtube.com/watch?v=vOMJlQ5B-M0&list=PLVvjrrRCBy2JSHf9tGxGKJ-bYAN_uDCUL)
- [YouTube大神用rust写了贪吃蛇游戏，这是他分享rust的ownership以及borrow概念](https://www.youtube.com/watch?v=8M0QfLUDaaA&list=LLFLN2ZAPopjz2zM-FomwnkQ&index=2&t=8s)
- [serde JSON反序列化的库](https://serde.rs/derive.html)
- [感谢reqwest库提供的网络请求解析JSON数据的Example](https://github.com/seanmonstar/reqwest/blob/master/examples/json_typed.rs)
- [极客学院上详细介绍Rust的Module用法的文章](https://wiki.jikexueyuan.com/project/rust-primer/module/module.html)
