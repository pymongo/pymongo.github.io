# [容器内 coredump 收集](/2022/03/docker_container_coredump_collect.md)

因为 C++/Rust 应用想通过 docker 镜像分发给客户时希望镜像体积尽可能小，所以都一般 release 时建议用 musl 编译 + alpine

虽然 musl 解决了高版本系统编译的可执行文件在低版本不能运行(glibc 只保证向后兼容)，但是 musl 的内存分配器等等组件的性能不如 glibc)

Rust 应用还有一个可观测性的记录就是 coredump 文件收集(毕竟你不能强行不让开发写 unsafe 代码啊)

coredump 相关的 kernel 参数配置项是 `/proc/sys/kernel/core_pattern` 对应 sysctl 的 kernel.core_pattern

## Read-only file system

因为 alpine 默认的 core_pattern 是 `/usr/lib/systemd/systemd-coredump %P %u %g %s %t %c %h` 

因为没装 systemd 只能改掉默认的 alpine kernel 配置

当我想在 alpine 改 kernel 参数就会报错，网上搜 `read-only file system`

所以 docker run 要加上 --privileged 参数

出于安全性考虑的设计 docker build 不允许带 --privileged 所以就不能在 Dockerfile 配置 coredump 收集

## 解除 coredump ulimit 限制

因为在容器内跑 ulimit 是没用的所以  docker run 加上参数 --ulimit core=-1

## 测试 alpine core 文件

最简单的产生 core 文件方法是 libc::raise(3)，那就在 alpine 装 alpine-sdk 写点 C 语言试试 

```
/ # echo "/root/cores/core.%e.%p" > /proc/sys/kernel/core_pattern
/ # vi c.c
/ # gcc c.c && ./a.out
Quit (core dumped)
/ # ls /root/cores/
core.a.out.23
```

所以 core_pattern 的 %e 应该是可执行文件名字，%p 是 pid
