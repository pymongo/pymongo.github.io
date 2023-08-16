# [volatile 不解决分支预测](/2023/08/volatile_and_cpu_branch_prediction.md)

之前看书碰见过 volatile 好几次一直没记笔记，最近看 程序员的自我修养 书中也提到了 volatile 所以得重视起来

根据 ptr::read_volatile 的文档: `guaranteed to not be elided or reordered by the compiler`

由于 CPU 读写速度远快于内存，所以 CPU 会分支预测某个 if 大概率走 true 分支的时候就会提前执行完 true 分支的指令

## 分支预测导致单例模式要 double check

显然 volatile 只能解决**编译器优化掉和重排** 并不能干预 CPU 分支预测提前执行

程序员的自我修养 书中说 引入 barrier 函数和 double-check 解决指令重排导致的单例初始化问题

## branch prediction side-channel attack

meltdown vulnerability/侧信道攻击

malware(恶意软件) 欺骗 CPU 利用分支预测提前执行的特点 提前读取其他进程的内存数据而不会 SIGSEGV

目前只能通过操作系统来防御这样分支预测的 malware

这个是 x86 乱序执行特性导致的漏洞，18 年前出厂的 CPU 设计上都有这个问题，RISC-V 的设计上就没有这个漏洞

## Dynamic Voltage and Frequency Scaling 漏洞
现代处理器遇到高计算量的任务的时候，会睿频动态提高处理器电压和频率，有漏洞利用这个特性组合其他漏洞甚至能跨核心获取 Intel SGX 安全执行环境内数据

目前没有较好解决办法，只能是增加噪音或者是执行安全代码的时候关闭睿频

---

所以说为了性能分支预测乱序执行，引入了安全问题，为了解决安全问题操作系统要额外的性能开销

```
以下是一些目前仍存在的由硬件设计缺陷导致的CPU漏洞：

Spectre漏洞：Spectre漏洞是一系列的漏洞，包括Spectre V1、V2和V4。这些漏洞利用了现代处理器中的执行预测和乱序执行特性，允许攻击者通过特殊的恶意代码，从受限制的内存中读取敏感数据。

Meltdown漏洞：Meltdown漏洞也利用了执行预测和乱序执行的特性，允许攻击者读取应该受限制的内核内存数据。Meltdown漏洞主要影响采用了乱序执行的处理器，如Intel的一些处理器。

Foreshadow漏洞：Foreshadow是一系列的漏洞，包括L1 Terminal Fault (L1TF)和Foreshadow-NG。这些漏洞允许攻击者从受限制的内存中读取机密数据，包括虚拟化环境中的数据。

Zombieload漏洞：Zombieload漏洞是一种侧信道攻击，利用了Intel处理器上的乱序执行特性，允许攻击者读取其他进程或虚拟机中的数据。

这些漏洞都是由于硬件设计缺陷而导致的，解决它们需要对受影响的处理器进行修复或改进。厂商通常会发布微码或固件更新来修复这些漏洞，同时操作系统也会提供补丁来增强安全性。然而，由于处理器的复杂性和广泛使用，完全解决这些漏洞可能需要更长时间。因此，建议用户及时更新操作系统和微码来减少风险。
```
