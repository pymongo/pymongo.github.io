# [learningOS](/2023/08/learning_os.md)

[国家智能网联的训练营/夏令营](https://mp.weixin.qq.com/s/yKHV40znJYoZBETf7D3MpA)课程是根据清华操作系统课程改编过来的

- <https://github.com/learningOS>
- <https://github.com/LearningOS/rust-based-os-comp2023/blob/main/relatedinfo.md>
- MIT RISC-V OS 实验: <https://pdos.csail.mit.edu/6.828/2021/tools.html>

OS 课缺失的 lecture7 可以看学堂在线公开课的版本

## 学习进度

书籍和课程视频

||||
|---|---|---|
|CSAPP| 看完了 |
|计算机组成与设计 RISC-V edition| ch2.3.2 | 常数 |
|OS Three easy pieces| 看完了 |
|rCore Tutorial Book| 看完了 |
|uCore Tutorial Book| ch4 | SV39 实现 |
|程序员的自我修养链接装载库| 看完了 |
|清华 os_lecture 2022| 看完了|
|清华操作系统(RISC-V) 学堂在线| 看完了+通过慕课考试 |
|南京大学操作系统 jyy 2022|lecture06 7min||

|||
|---|---|
|MIT 6.828 Operating System Engineering| |
|xv6 a simple Unix-like teaching operating system| |

一些作业/实验的代码仓库，都可以通过切分支来切换到不同实验，例如 rCore 的第一个实验可以切换到 ch1 分支

一些内容量较少的课或书
||||
|---|---|---|
|ArceOS 设计&实现 阿图教育|linux 内核驱动开发基础|
|ArceOS Tutorial Book|看完了|

## 预备知识

### CSAPP
考虑到分支预测 流水线 cache_line 等内容在我之前看过的一些书也学过，时间关系这本书我暂时跳过

### RISC-V 版计算机组成原理

为什么不用最常用的 x86 是因为 x86 复杂指令集，ARM/MIPS 虽是精简指令但不开源指令数量非常多

RISC-V 只有 40 多个指令非常适合初学者入门学完之后构建一个操作系统

- 英文书名: computer organization and design RISC-V edition ()
- 中文书名: 计算机组成与设计: 硬件/软件接口

> 另一本经典名著《计算机体系结构量化研究方法》也是同一个出版机构(伯克利分校)出版的

前两章重点看完，后面章节按需看

### 链接装载库
1. gcc/g++ preprocess: .c/.cpp -> .i/.ii
2. cc/cc1(not include lex/yacc) compile and as(assembler): .i/.ii -> .o （relocatable file）
3. ld linker: one or multi .o -> elf

## textbook
https://pages.cs.wisc.edu/~remzi/OSTEP/

好处一内容面向操作系统的使用者和应用层开发，稍比那些简单

好处二官方有在线阅读的中文版: <https://pages.cs.wisc.edu/~remzi/OSTEP/Chinese/>

### 为什么书名叫 Three Easy Pieces
虚拟化/并发/持久化三个难点三座大山

### 课程实践参考书
- uCore tutorial book
- rCore tutorial book

---

## 操作系统概述

### 如何定义操作系统
对底层硬件访问进行抽象并虚拟化，控制程序执行过程防止错误(coredump)

未来的操作系统?
IOT,分布式操作系统，边缘计算

RISC-V 页机制
与 SIGABRT/SIGSEGV 多次打交道的我早已熟悉多个应用虚拟内存互相隔离，地址空间这些

### 操作系统 bug 非常多
写过操作系统的都知道漏洞非常非常多，多到 bugfix 因此也就有了网络空间安全这样专门找 bug 的专业
### 特权模式

例如一些访问底层硬件的指令只能在特权模式下执行，x86/ARM/RISC-V 都有这样的机制，通过中断从普通模式到特权模式的来回切换

linux 将特权模式抽象成 kernel-space

## 信号(软中断)不如硬件中断及时性的原因
进程收到信号上只是在 TrapContext 存储了信号和信号回调地址，并不会立即执行信号回调(rcore 是，linux 应该不是)

等到进程下一次进入 trap 才会执行信号回调，如果进程一直没系统调用最坏的情况下跑完一个时间片后进入 trap 才会处理信号

```
当信号处理程序执行完毕后，如果没有调用sigreturn系统调用，那么程序将会继续执行信号处理程序之前的指令，而不是返回到被中断的地方。因此，在信号处理程序中，如果需要恢复执行状态并返回到被中断的地方，需要显式调用sigreturn系统调用。

处理信号时，内核会自动处理信号的返回问题，你不需要手动调用sigreturn或rt_sigreturn。通常情况下，信号处理回调函数只需要完成一些轻量级的操作，例如修改全局变量、发送信号到其他进程等。
sigreturn和rt_sigreturn系统调用主要用于在特定的场景下恢复复杂的信号处理程序状态，例如在信号处理程序中实现自定义的信号栈、修改寄存器状态等

不完全正确。在Linux中，进程收到信号后，并不是要等到下一次陷入内核态时才会处理信号。实际上，信号处理是异步的，进程在任何时刻都可能收到信号并触发信号处理程序。

当进程收到信号时，内核会中断进程的正常执行流程，并在进程的上下文中执行信号处理程序。这可能发生在进程的用户态或内核态。进程在处理完信号后，会根据处理方式的不同，继续执行原来的指令或者根据信号处理程序所指定的操作进行处理。

然而，有一些情况下，进程在一些特定的操作中会阻塞信号的处理。例如，在某些系统调用（如read、write、sleep等）期间，进程可以选择阻塞信号，直到系统调用完成后才处理信号。这样做的目的是确保特定操作的原子性或避免异常情况下的竞态条件
```

## rcore/linux 的 fork 有何不同
rcore 的 process control block 包含了线程数组，因此 fork 的时候线程也会复制一份，但 linux fork 只是当前进程复制不会有子线程复制。(当然 rcore 源码现在优化了，fork 不复制线程了)

## 对称/非对称 coroutine
非对称的不能从 callee 切换到 caller 也就是 task 之间是不对等的，task1 能切 task2 反之不行

有栈协程好处是可以在任意函数位置中挂起，而无栈不行(因为上下文数据在堆上)

## eventfd
用户空间程序可以创建一个事件对象，并设置初始的计数值。然后，程序可以使用read系统调用等待事件的发生。当事件发生时，read调用将返回。eventfd在Linux中被广泛用于异步编程、事件驱动编程、线程同步和多线程通信等场景

## 网卡设备用中断+轮询更高效
网卡和显卡都是高速设备，如果一次 IO 就要中断 CPU 一次会过于频繁导致活锁问题

网卡是没数据时等数据中断 CPU 建立 socket 之后 CPU 不断轮询数据直到通信结束，网卡是中断为主轮询为辅的 IO 处理，像键盘这样低速设备纯中断通知效率更高

CPU主要有三种方式可以与外设进行数据传输：Programmed I/O (简称PIO)、Interrupt、Direct Memory Access (简称DMA)

PIO方式可以进一步细分为基于Memory-mapped的PIO（简称MMIO）和Port-mapped的PIO（简称PMIO

## 总线
对于 PC 机来说总线通常显卡/网卡/固态/内存连 PCIE 高速总线

对于树莓派这样的 SOC 来说总线通常来说也叫 Platform 总线

dtb 设备树有五个设备可以理解成总线上有五个空的"插槽"，这些空插槽必须让驱动和设备关联起来才能用

要么是设备先注册到总线，然后驱动去总线设备列表找关联的设备，要么反之驱动先注册到总线再遍历设备

## /var/log/kern.log
dmesg 是内存 ring buffer 里面的 kernel log, kern.log 是持久化之后的 kernel log

---

## 清华操作系统学堂在线慕课考试——查缺补漏
在RISC-V的中断处理过程中，中断来源保存在哪个寄存器——mcause

根据已分配的数目，slab内存分配有哪几种缓冲队列  
```
Full（满）队列：这个队列包含已分配的所有slab对象。当一个slab对象被分配完时，它会从Partial（部分）队列移动到Full队列。Full队列中的slab对象不能再被分配，只有在被释放后才能回到Empty（空）队列。
Partial（部分）队列：这个队列包含部分已分配的slab对象。当一个slab对象被部分分配之后，它会从Empty队列移动到Partial队列。Partial队列中的slab对象可以被继续分配给新的内存请求。
Empty（空）队列：这个队列包含尚未分配的slab对象。当内存请求到来时，可以从Empty队列中获取一个空的slab对象，并将其分配给请求者。Empty队列是新的、未使用的slab对象的初始位置。

这些队列的目的是为了在内存分配中提高效率。通过将已分配的slab对象放入Full队列，对部分分配的slab对象放入Partial队列，以及将未分配的slab对象放入Empty队列，可以方便地管理和分配可用的内存块。这种机制可以减少内存碎片化，提高内存分配和回收的效率。
```

填空题，请给出"未作答"部分应该填入的内容
物理页帧分配不会产生 未作答 碎片，只会产生不大于物理页帧大小的 未作答 碎片。
物理页帧分配不会产生内部碎片，只会产生不大于物理页帧大小的外部碎片。


填空题，请给出"未作答"部分应该填入的内容
每个页面对应一个页表项，页表项中至少需要包括的三种标志是 未作答 、 未作答 和 未作答 。
有效位（Valid Bit 是否在内存中）、访问位（Accessed Bit）和修改位（Dirty Bit）

在采用Sv32页式存储管理的RISC-V系统中，每个页表项占据4字节（32位）。
一个页表包含1024个页表项，因此一个页表占用的总字节数为1024 * 4 = 4096字节（4KB）。
在Sv32模式下，一级页表有1024个表项，每个表项指向一个二级页表，二级页表也有1024个表项。所以总共有1024 * 1024 = 1048576个二级页表项。
因此，所有页表项总共占用的字节数为1048576 * 4 = 4194304字节（4MB）。

CFS（Completely Fair Scheduler）调度器中，每个线程都有一个虚拟运行时间（vruntime）参数。vruntime的值越大，表示该线程在过去的调度周期中运行的时间越少，因此它有更高的优先级，有更多的机会获得CPU执行时间

## MIT OS lab

MIT 的 git 仓库要认证才能使用 git://g.csail.mit.edu/xv6-labs-2021

github 上面有人分享了这个 https://github.com/mit-pdos/xv6-riscv

安装 riscv 工具链 <https://pdos.csail.mit.edu/6.828/2021/tools.html>

(重点看) 如何用 gdb/addr2line 调试报错 <https://pdos.csail.mit.edu/6.828/2021/labs/guidance.html>

## perCPU 概念
类似 threadLocal linux 每个核心的 L1 缓存都有独占的数据记录调度信息

arceos 的多核模式下有分 **主核** 和副核

主核就无限 yield 进入低功耗等中断模式让控制权交给应用，多个核心通过 spinlock 获取同一个任务队列
