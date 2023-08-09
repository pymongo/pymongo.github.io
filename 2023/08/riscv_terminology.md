# [RISC-V 术语](/2023/08/riscv_terminology.md)

||||
|---|---|---|
|TLB|Translation Lookaside Buffer|cache virtual-to-physical address translation|
|AMO|Atomic Memory Operations|exception code 6: Store/AMO address misaligned|
|CSR|control and status register||
|sfence.vma|指令|刷新 TLB 缓存|
|wfi|指令|进入低功耗状态等待中断|
|.quad|汇编|8 byte 在 riscv64 其实就是 usize|
|.incbin|汇编|约等于 Rust include_bytes!|
|fence.i|原子汇编指令|其实作用就是替换代码段后清空处理器指令缓存 i-cache|