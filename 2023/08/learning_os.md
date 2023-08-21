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
|CSAPP| ch2.2.3 | 补码 |
|计算机组成与设计 RISC-V edition| ch2.3.2 | 常数 |
|OS Three easy pieces| ch5 |  |
|rCore Tutorial Book| ch6.2 | 文件系统 |
|uCore Tutorial Book| ch4 | 地址空间 |
|程序员的自我修养链接装载库| 看完了 |
|清华 os_lecture 2022| lecture13 00:38:00 | 线程 |
|清华操作系统(RISC-V) 学堂在线| 21.1 | 异步编程 |
|ArceOS Tutorial Book|看完了|
|南京大学操作系统 jyywiki.cn/OS/2022/|||

|||
|---|---|
|MIT 6.828 Operating System Engineering| |
|xv6 a simple Unix-like teaching operating system| |

一些作业/实验的代码仓库，都可以通过切分支来切换到不同实验，例如 rCore 的第一个实验可以切换到 ch1 分支

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
进程收到信号上只是在 TrapContext 存储了信号和信号回调地址，并不会立即执行信号回调

等到进程下一次进入 trap 才会执行信号回调，如果进程一直没系统调用最坏的情况下跑完一个时间片后进入 trap 才会处理信号

```
当信号处理程序执行完毕后，如果没有调用sigreturn系统调用，那么程序将会继续执行信号处理程序之前的指令，而不是返回到被中断的地方。因此，在信号处理程序中，如果需要恢复执行状态并返回到被中断的地方，需要显式调用sigreturn系统调用。

处理信号时，内核会自动处理信号的返回问题，你不需要手动调用sigreturn或rt_sigreturn。通常情况下，信号处理回调函数只需要完成一些轻量级的操作，例如修改全局变量、发送信号到其他进程等。
sigreturn和rt_sigreturn系统调用主要用于在特定的场景下恢复复杂的信号处理程序状态，例如在信号处理程序中实现自定义的信号栈、修改寄存器状态等
```

## 对称/非对称 coroutinue
非对称的不能从 callee 切换到 caller 也就是 task 之间是不对等的，task1 能切 task2 反之不行

有栈协程好处是可以在任意函数位置中挂起，而无栈不行(因为上下文数据在堆上)

---

## MIT OS lab

MIT 的 git 仓库要认证才能使用 git://g.csail.mit.edu/xv6-labs-2021

github 上面有人分享了这个 https://github.com/mit-pdos/xv6-riscv

安装 riscv 工具链 <https://pdos.csail.mit.edu/6.828/2021/tools.html>

(重点看) 如何用 gdb/addr2line 调试报错 <https://pdos.csail.mit.edu/6.828/2021/labs/guidance.html>
