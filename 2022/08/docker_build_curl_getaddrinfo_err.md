# [docker build curl err](/2022/08/docker_build_curl_getaddrinfo_err.md)

公司有台装了 docker 19 的 ubuntu 20.04 机器(运维说的随便百度找的 K8s 离线安装压缩包全是 binary 的，优点是离线安装和低版本 K8s 还用 docker 引擎没用 containerd 所以版本比 apt 源的低)

里面构建任何发行版的 Dockerfile 都算正常，但是跑 fedora 装包时必然报错

> Curl error (6): Couldn't resolve host name for https://mirrors.fedoraproject.org

之前遇到过这样的报错是开关 ExpressVPN(OpenVPN) 导致宿主机网络变化，重启 docker 就好

但这次重启也不管用了

## 错误排查的尝试

以下方法通通没用

- 用清华 fedora 源
- 改 DNS

后来在想会不会根本不是网络的原因？另一个 ubuntu 20.04 的机器从 apt 装的 docker 能正常运行的，会不会是 docker 自身问题？

果然从另一个机器拷贝一个装了 ping(dnf install iputils) 的镜像运行，ping 正常，curl 任何网址都报错

此时按 `curl error (6)` 和 `docker build` 关键词去搜根本没有有用的信息

## strace 排查

这是 curl 报错的 strace

```
socketpair(AF_UNIX, SOCK_STREAM, 0, [5, 6]) = 0
rt_sigaction(SIGRT_1, {sa_handler=0x7f27e6bf13d0, sa_mask=[], sa_flags=SA_RESTORER|SA_ONSTACK|SA_RESTART|SA_SIGINFO, sa_restorer=0x7f27e6ba5ac0}, NULL, 8) = 0
rt_sigprocmask(SIG_UNBLOCK, [RTMIN RT_1], NULL, 8) = 0
mmap(NULL, 8392704, PROT_NONE, MAP_PRIVATE|MAP_ANONYMOUS|MAP_STACK, -1, 0) = 0x7f27e586a000
mprotect(0x7f27e586b000, 8388608, PROT_READ|PROT_WRITE) = 0
rt_sigprocmask(SIG_BLOCK, ~[], [], 8)   = 0
clone3({flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, child_tid=0x7f27e606a910, parent_tid=0x7f27e606a910, exit_signal=0, stack=0x7f27e586a000, stack_size=0x7ffe00, tls=0x7f27e606a640}, 88) = -1 EPERM (Operation not permitted)
```

从 apt install docker-ce 中 curl 的 strace 正常结果

```
socketpair(AF_UNIX, SOCK_STREAM, 0, [5, 6]) = 0
rt_sigaction(SIGRT_1, {sa_handler=0x7fa3f75653d0, sa_mask=[], sa_flags=SA_RESTORER|SA_ONSTACK|SA_RESTART|SA_SIGINFO, sa_restorer=0x7fa3f7519ac0}, NULL, 8) = 0
rt_sigprocmask(SIG_UNBLOCK, [RTMIN RT_1], NULL, 8) = 0
mmap(NULL, 8392704, PROT_NONE, MAP_PRIVATE|MAP_ANONYMOUS|MAP_STACK, -1, 0) = 0x7fa3f617e000
mprotect(0x7fa3f617f000, 8388608, PROT_READ|PROT_WRITE) = 0
rt_sigprocmask(SIG_BLOCK, ~[], [], 8)   = 0
clone3({flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, child_tid=0x7fa3f697e910, parent_tid=0x7fa3f697e910, exit_signal=0, stack=0x7fa3f617e000, stack_size=0x7ffe00, tls=0x7fa3f697e640}, 88) = -1 ENOSYS (Function not implemented)
clone(child_stack=0x7fa3f697ddf0, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM|CLONE_SETTLS|CLONE_PARENT_SETTID|CLONE_CHILD_CLEARTID, parent_tid=[22], tls=0x7fa3f697e640, child_tidptr=0x7fa3f697e910) = 22
```

果然拿 docker + clone3 + EPERM 去搜索就找到 moby(docker) 的 issue 了

<https://github.com/docker/buildx/issues/772>

于是让运维卸载掉 K8s 离线工具的 docker 再 apt install docker 就彻底解决 curl 在 fedora 不能用的问题了
