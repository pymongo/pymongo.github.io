# [alpine sh not found](/2022/04/alpine_sh_not_found.md)

发现 alpine linux 的 `sh: command not found` 除了可执行文件不存在之外，还有一种可能就是 ld-linux (可执行文件的解释器?) 版本太低导致 ld-linux 找不到所以显示 sh: not found

如果 Rust 程序有 C/C++ 一些动态库依赖之后打成 musl 就加入了 ld-linux 的版本信息到可执行文件(无法做成 static linked) 建个高版本 ld-linux 软链接即可解决

https://twitter.com/ospopen/status/1514953405269430272

## musl 带 C 动态库依赖

需求: 由高版本的 archlinux 编译出 musl 给 centos8 用，包含 python 和 zmq 的动态库

除了 rustcflags 要加上 `-Ctarget-feature=-crt-static` 之外，还有设置下 PYO3_PYTHON 环境变量的路径，
以及 PKG_CONFIG_SYSROOT_DIR=/usr/lib (zmq 用的 pkgconf 那个库设置的交叉编译引用的动态库路径)

参考: https://dustri.org/b/error-loading-shared-library-ld-linux-x86-64so2-on-alpine-linux.html

```
FROM alpine
RUN apk add --no-cache python3-dev zeromq
COPY config/kernel-123-kernel_id.json /etc/
COPY target/x86_64-unknown-linux-musl/release/idp_kernel /usr/bin/
RUN ln -s /lib/libc.musl-x86_64.so.1 /lib/ld-linux-x86-64.so.2
ENTRYPOINT [ "/lib/ld-linux-x86-64.so.2", "/usr/bin/idp_kernel", "-f", "/etc/kernel-123-kernel_id.json" ]
```
