# [Rust and actix](/2020/04/rust.md)

ruby/rails的性能不能满足实时性很强的需求(股票交易所)，于是尝试下[据说世界第一快的API框架](https://www.techempower.com/benchmarks/)
rust/actix

## rust安装

<i class="fa fa-hashtag"></i>
用rustup安装不要用brew/apt

rust官方不推荐使用homebrew/apt-get的包管理工具去安装，建议使用rustup(类似npm)

> curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

按1选择默认的安装路径

<i class="fa fa-hashtag"></i>
环境变量

```
github.com/rust-lang/rustup 文档的第1~2段话
$HOME/.cargo/bin will be in your $PATH environment variable, which means you can run them from the shell without further configuration.

Open a **new shell** and type the following:
```

意思是安装完后打开一个新的terminal就能

<i class="fa fa-hashtag"></i>
Intellij创建Rust项目

设置`Toolchain location`: /Users/w/.cargo/bin 之后 Intellij会提示

`Download Standard Library via rustup`

然后帮我把rust标准库下载到

> /Users/w/.rustup/toolchains/stable-x86_64-apple-darwin/lib/rustlib/src/rust/src
