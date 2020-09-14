# [mac交叉编译Rust到Linux](/2020/09/mac_cross_compile_rust_to_linux.md)

Rust的交叉编译命令确实像Go语言那样简单

例如Go是: GOOS=linux go build

而Rust则是: cargo build --target=x86_64-unknown-linux-gnu

但是Rust最大问题是mac没有Linux的编译器和所需的SDK

> brew install FiloSottile/musl-cross/musl-cross

安装完后会提示:

```
GNU "sed" has been installed as "gsed".
If you need to use it as "sed", you can add a "gnubin" directory
to your PATH from your bashrc like:

    PATH="/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"
==> make
GNU "make" has been installed as "gmake".
If you need to use it as "make", you can add a "gnubin" directory
to your PATH from your bashrc like:

    PATH="/usr/local/opt/make/libexec/gnubin:$PATH"
```

Linux下Rust默认使用unknown-linux-gnu，但是mac平台交叉编译到Linux只能用unknown-linux-musl

之后在.cargo/config里加上

```
[target.x86_64-unknown-linux-musl]
linker = "x86_64-linux-musl-gcc"
```

这个linker的路径会在:

/usr/local/opt/musl-cross/bin/x86_64-linux-musl-cpp

## 交叉编译的openssl问题

如果交叉编译的项目含有第三方库，例如这个[issue](https://github.com/zonyitoo/context-rs/issues/31)，一般需要加上CROSS_COMPILE环境变量:

CROSS_COMPILE=x86_64-linux-musl cargo build --target=x86_64-unknown-linux-musl --features vendored

否则会报错: Is `musl-gcc` not installed?

如果rust项目含有openssl的依赖，暂时还是只能放弃交叉编译的想法了

https://github.com/sfackler/rust-openssl/issues/495

我照着rust-openssl issue#980的做法，强制静态链接openssl库成功交叉编译

TODO 什么是编译时库的动态链接/静态链接?

TODO 为什么openssl使用静态链接就能交叉编译?

https://github.com/sfackler/rust-openssl/issues/980

最终交叉编译的命令如下:

> CROSS_COMPILE=x86_64-unknown-linux-musl cargo build --target=x86_64-unknown-linux-musl --features vendored

## 交叉编译的优缺点

优点:

- 生产服务器上不需要安装git/rustup/libssl等，不需要连外网安装各种库/编程语言SDK
- 部署快，通常二进制文件在8-10M左右，scp发给服务器改下current软链接之后重启即可完成部署
- 节省服务器的硬盘空间，capistrano每次拉代码都要全新编译(因为改了软链接)，release编译占用500M，debug编译占用3G硬盘空间，服务器只归档二进制文件时能节约大量硬盘资源
- 杜绝线上/生产服务器上直接改代码的恶习 

缺点:

- 编译慢，linux上编译了291个crate，mac上交叉编译要编译426个crate
- 交叉编译生成的二进制文件较大(11M)，在Linux下编译生成的二进制文件是8M

缺点基本上可以通过在mac上使用docker的Linux虚拟机去编译Rust代码得到解决，所以我看论坛/博客上大部分人都是交叉编译/在docker上编译成可执行文件再发到服务器上完成部署
