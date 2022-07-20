# [docker illegal instr](/2022/07/docker_container_core_dumped_illegal_instruction.md)

```
https://twitter.com/ospopen/status/1544970889925885952

尝试在 ubuntu:20.04 中运行 fedora:36 镜像中的应用，
结果发现用了 libc 函数的可执行文件启动就 coredump
illegal instruction (core dumped)
没用 libc 的能运行但也会跑着跑着 coredump

看来还是高版本 glibc 编译出来的可执行文件不能在低版本系统运行的限制
```

但我觉得是 fedora:36 的 glibc 2.35 发生了一些不兼容改动吧，
毕竟公司生产服务器上宿主机 centos7 常年跑 centos8/ubuntu:20.04 的应用也没问题

但实际原因是云产商的 centos7 不一定是 3.10 的内核，我司的生产服务器上是 4.19 甚至 5.4 内核版本的都有

容器内没有捕获 coredump 的话，coredump 会记录在宿主机的 dmesg

```
[10280346.484842] traps: tokio-runtime-w[1589335] trap invalid opcode ip:558c4a678352 sp:7ff2b2b37700 error:0 in lsp[558c4a4ee000+197000]
[10280351.307634] traps: tokio-runtime-w[1589353] trap invalid opcode ip:55bddbd74352 sp:7f8814f17700 error:0 in lsp[55bddbbea000+197000]
[10280355.869082] traps: tokio-runtime-w[1589380] trap invalid opcode ip:56259ccb0352 sp:7f9543c54700 error:0 in lsp[56259cb26000+197000]
[10280358.901880] traps: tokio-runtime-w[1589407] trap invalid opcode ip:562a5adfd352 sp:7f2f8d692700 error:0 in lsp[562a5ac73000+197000]
[10280363.141340] traps: tokio-runtime-w[1589419] trap invalid opcode ip:5597117c7352 sp:7fe25fff9700 error:0 in lsp[55971163d000+197000]
[10280368.227822] traps: tokio-runtime-w[1589435] trap invalid opcode ip:5652bf179352 sp:7fed0f6a2700 error:0 in lsp[5652befef000+197000]
[10280371.628575] traps: tokio-runtime-w[1589456] trap invalid opcode ip:55a937fe7352 sp:7f929799f700 error:0 in lsp[55a937e5d000+197000]
[10280377.684379] traps: tokio-runtime-w[1589469] trap invalid opcode ip:5560a22c4352 sp:7f481d949700 error:0 in lsp[5560a213a000+197000]
[10280382.626834] traps: tokio-runtime-w[1589485] trap invalid opcode ip:55cccfa0c352 sp:7f6998ef4700 error:0 in lsp[55cccf882000+197000]
[10280388.522389] traps: tokio-runtime-w[1589499] trap invalid opcode ip:55d9b221d352 sp:7f378b71c700 error:0 in lsp[55d9b2093000+197000]
```
