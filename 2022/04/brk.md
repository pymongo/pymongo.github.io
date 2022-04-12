# [brk](/2022/04/brk.md)

用 strace -f 看进程系统调用(-f 参数表示记录子进程调用)时经常能看到 brk(NULL) 这个系统调用，因好奇而写下本文

## brk 与进程地址空间

brk/sbrk 看上去就是设置进程地址空间的 BSS(放常量字符串的) 区跟堆之间的分界线指针

<https://www.cnblogs.com/arnoldlu/p/10272466.html>

这篇文章说 top 里面 VIRT 列是虚拟内存占用而 RES 列才是实际占用内存

## ldd 动态库

```
ldd a.out 
	linux-vdso.so.1 (0x00007ffcd9db5000)
	libc.so.6 => /usr/lib/libc.so.6 (0x00007f6e57fc3000)
	/lib64/ld-linux-x86-64.so.2 => /usr/lib64/ld-linux-x86-64.so.2 (0x00007f6e58202000)
```

1. vdso 是为了解决 glibc 跟内核版本兼容问题
2. libc.so 我很熟悉了
3. ld-linux-x86-64.so 是所有带动态库可执行文件的 linker + 解释器?

也就 ./a.out 的执行会变成 /lib64/ld-linux-x86-64.so.2 ./a.out 然后再 execve

rust 应用会额外多一个 libgcc_s.so 的动态库引入 gcc runtime 的一些符号和 main/_start 函数吧

## clone & fork

国内的文章喜欢说 clone 是轻量级的 fork

不管是 clone 还是 fork 复制当前进程都是 Copy On Write 开销较小

Rust 的 spawn 用的是 clone (不清楚什么时候会用 posix_spawn)

根据 man 文档说也就 clone 提供了更细粒度的子进程控制，例如父子进程共享虚拟内存

## strace 必经流程

1. execve
2. brk
3. mmap (进程地址空间动态库)
