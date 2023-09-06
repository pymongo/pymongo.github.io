# [冯/哈佛架构混合?](/2023/09/von_neumann_and_harward_architecture.md)

x86,RISC-V,大部分 ARM 都是冯诺依曼架构，嵌入式/工控领域用哈佛架构(指令数据分开提高吞吐量)

工控对安全要求高不能让运行时程序把代码段的数据覆盖掉，嵌入式没操作系统又不能用只读内存页保护代码段。参考阅读体系结构量化研究方法那本书

## 面试题: 指针的大小一定是 usize 吗？

在冯诺依曼架构的CPU上一定是，在哈佛架构的CPU上不一定

哈佛架构的 instruction_memory,data_memory 的位宽可能不一样

## ARM 到底是冯诺依曼架构还是哈佛架构
现在的 CPU 都是混合架构? x86 在 L1 cache 分指令缓存和数据缓存

Cortex-A/Cortex-R 是哈佛的，低功耗的 Cortex-M 是冯诺依曼架构

> irom和iram是用于SoC引导和启动的,芯片上电后首先会执行内部irom中固化的代码,就好像一个MCU一样，irom就是他的flash，iram就是他的SRAM，这又是典型的哈佛结构。所以bootloader固件中像哈佛架构，开机后又变成冯架构

## bitwidth of ATmega328P instruction/data memory/bus
data memory/bus 8bit, instruction 16bit, but PC is 14bit=16kb and 32kb flash

> ATmega328P microcontroller does not have a dedicated instrument bus

芯片文档说 AVR 指令寻址都是 16/32 位宽，所以 14bit PC 怎样扩展成 16 位寻址很神奇我还没想到

> Since all AVR instructions are 16 or 32 bits wide, the flash is organized as 16Kx16. For software security, the flash program memory space is divided into two sections, boot loader section and application program section in ATmega328P.

## 为何 ATmega328P 内存只有 2kb
应用程序的代码数据放在 flash 上，我理解 elf 文件的只读部分例如 .code 在 flash 上，所以只有全局变量和堆栈在 2kb 的 SRAM 上

很多嵌入式设备都这样，卖的 SOC 自带的 SRAM 很小，靠第三方厂商加内存通过 bootloader 一级一级打开这些更大的内存

## EEPROM≈硬盘
在 Arduino UNO 上是的，但 EEPROM 还能当内存用，用来存放代码且执行代码

参考 Execute In Place [XIP 技术总结](https://zhuanlan.zhihu.com/p/368276428)
