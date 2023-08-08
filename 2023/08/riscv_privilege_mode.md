# [特权级机制](/2023/08/riscv_privilege_mode.md)

<https://learningos.github.io/rCore-Tutorial-Book-v3/chapter2/1rv-privilege.html>

对指令/控制的隔离: 特权级机制，地址空间对数据隔离，中断对时间隔离，对破坏/malware 的隔离是异常处理

包括 Machine Mode, Supervisor Mode, User Mode, (optional)Hypervisor mode

用户态的程序只能访问通用寄存器，内核态的程序可以访问控制状态寄存器

具体用什么模式看业务场景 M-mode 是必备的，例如点亮一个 LED 灯的超简单嵌入式场景应用就只需要 M mode

如果希望 CPU 内置 MMU(memory manage unit) 去做虚拟内存到物理这样比 OS 层做地址翻译效率更高

所以 PS5/amd 的家用机处理器是 M,S,U,H 模式通通存在的

在 RISC-V 中 ecall 指令从 U->S 或者 U->M 取决于业务场景的 context 如果简单嵌入式场景一次 ecall 就能从 U/S -> M 一次 ecall 只能跨越一级

CSR(Control and Status Register)/mstatus

准确来说 ecall/eret 是特权提高一级，在 rcore 教程中只会涉及 S/U 两个模式德切换，对 RustSBI 所在的 M 级别不做深入探讨

## ecall and sret/mret

环境调用异常: ecall 时产生

sret/mret 跟 ecall 成对出现起 return 效果

- sret: supervisor mode return
- mret: machine mode return

规律: riscv 命名上 m/s mode 状态下特有的命令/寄存器会命名成 m/s 前缀，例如 mret,mstatus 和 sret,sstatus
