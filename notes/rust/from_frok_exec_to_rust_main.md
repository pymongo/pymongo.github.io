# 从Linux创建进程到进入Rust可执行文件的main函数的过程

之前看了篇[文章](https://mp.weixin.qq.com/s/YsqoIfFZkHw1pEzsdkfo9Q)，介绍Linux系统从创建进程到C语言可执行文件的过程，我试试用Rust走一遍文章的步骤

Linux系统内核通过fork创建一个完全一样的子进程

想让子进程运行不同的可执行程序，还需要用exec系统调用「替换掉fork出来的子进程的可执行程序」

exec系统调用过程中一个重要工作就是加载可执行文件到进程的虚拟内存空间，提取出可执行文件ELF中的入口地址(在windows上ELF称为PE)

假设Rust编译生成的可执行文件的文件名叫r，使用`readelf -l`可以发现`Entry point 0x4710`这个内容

```
$ readelf -l r

Elf file type is DYN (Shared object file)
Entry point 0x4710
There are 10 program headers, starting at offset 64
```

`Entry point 0x4710`就表示入口地址是0x4710

再用反汇编工具`objdump -d r > r.s`搜索4710地址

```
Disassembly of section .text:

0000000000004710 <_start>:
    4710:       31 ed                   xor    %ebp,%ebp
    4712:       49 89 d1                mov    %rdx,%r9
    4715:       5e                      pop    %rsi
    4716:       48 89 e2                mov    %rsp,%rdx
    4719:       48 83 e4 f0             and    $0xfffffffffffffff0,%rsp
    471d:       50                      push   %rax
    471e:       54                      push   %rsp
    471f:       4c 8d 05 ca e9 02 00    lea    0x2e9ca(%rip),%r8        # 330f0 <__libc_csu_fini>
    4726:       48 8d 0d 53 e9 02 00    lea    0x2e953(%rip),%rcx        # 33080 <__libc_csu_init>
    472d:       48 8d 3d cc 01 00 00    lea    0x1cc(%rip),%rdi        # 4900 <main>
    4734:       ff 15 86 d5 23 00       callq  *0x23d586(%rip)        # 241cc0 <__libc_start_main@GLIBC_2.2.5>
    473a:       f4                      hlt
    473b:       0f 1f 44 00 00          nopl   0x0(%rax,%rax,1)
```

发现其中一行是`callq __libc_start_main`，C/C++反汇编的入口地址调用的也是操作系统的__libc_start_main
