# [中断和 trap](/2023/08/riscv_interrupt_and_trap.md)

RISCV 目前有三种中断

软中断 IPI=Internal Processor Interrupt 通过往内存寄存器中存数来触发，例如核心一发出软中断通知核心二

软中断也是 core local interrupt?

时钟中断 stimecmp stime 时钟硬件定时会发出中断

Platform level interrupt controller 外设中断


## 中断相关背景知识

### riscv 中断相关寄存器(CSR)

- sstatus: 保存全局中断的使能位
- sie: 能处理或忽略的中断
- stvec: 指向中断服务总控函数入口

对应 rcore 源码的 汇编代码 __alltraps 和 interrupt::init 

sstatus 要设置成 sie

### 中断向量表
收到哪种中断后，查表得到内存地址再去跳转到这个内存地址

## nested interrupt
家用机都是支持嵌套中断，初期教学实验中我们可以暂不支持

注意不支持嵌套中断的操作系统中，当中断处理中的时候，必须关闭全局中断使能位，防止中断处理中时又发生另一个中断

## Is IO/timer interrupt also a trap in riscv
```
No, I/O and timer interrupts are not considered traps in RISC-V. Traps in RISC-V are typically exceptions or interrupts that are caused by specific events during program execution, such as illegal instructions, memory access faults, or environment calls.

I/O and timer interrupts, on the other hand, are external events triggered by devices or timers. They are not treated as traps but rather as interrupts in the RISC-V architecture. When an I/O or timer interrupt occurs, the processor suspends the current execution and jumps to an interrupt handler routine to handle the interrupt. Once the interrupt handler has completed its task, the processor resumes the interrupted program.

Interrupts and traps serve different purposes in RISC-V. Interrupts allow the processor to handle events from external devices asynchronously, while traps are primarily used for handling exceptional conditions or invoking privileged operations within the program flow.
```

trap 更多指的是内部"软中断"事件，例如内存访问越界、environment call from user mode

S mode 的操作系统发现用户态触发了异常/trap 再判断下如果异常是 malware 恶意软件例如内存越界访问就杀掉进程，如果是系统调用就继续往下传递 ecall 给 SBI

---

## TLB
Translation Lookaside Buffer, cache virtual-to-physical address translation
