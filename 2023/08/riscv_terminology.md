# [RISC-V 术语](/2023/08/riscv_terminology.md)

||||
|---|---|---|
|TLB|Translation Lookaside Buffer|(中文叫快表)cache virtual-to-physical address translation|
|AMO|Atomic Memory Operations|exception code 6: Store/AMO address misaligned|
|CSR|control and status register||
|sfence.vma|指令|刷新 TLB 缓存|
|wfi|指令|进入低功耗状态等待中断|
|.quad|汇编|8 byte 在 riscv64 其实就是 usize|
|.incbin|汇编|约等于 Rust include_bytes!|
|fence.i|原子汇编指令|其实作用就是替换代码段后清空处理器指令缓存 i-cache|
|DTB pointer|Device Tree Blob|引导程序加载 DTB 到内存并将地址传递给内核启动参数，内核根据设备树初始化硬件|
|Buddy Allocator|伙伴分配器|linux 大块堆内存用 buddy 小块内存用链表|
|CFS|Completely Fair Scheduler|时间片公平调度，linux 默认调度策略|
|SMP|Symmetric(对称) Multiprocessing scheduling|
|.got|Global Offset Table|动态库运行时寻址 dynamic symbol resolution during runtime|
|.percpu|per-cpu data|
|bl|branch and link|call subroutine to target label, 类似 include! 的效果，例子在 arceos trap.S 和 boot.rs|
|Stride|调度算法|
|AMO|atomic memory operation|
|TCB|thread control block|
|TLSF|Two-Level Segregated Fit|内存分配算法;segregated:隔离;申请和释放都是O(1)固定时间适合嵌入式实时操作系统|
|PMD|Peripheral Module Driver 外设模块驱动程序|

## 页表相关术语

|||
|---|---|
|page|逻辑页|
|frame|物理页|
|ppn|page physics number|
|va|virtual address|
|pa|physics address|
|pte|page table entry(存页表可读可写等元信息)|
|satp|supervisor address translation and protection|

地址空间(MemorySet)=PageTable(操作系统)+MapArea(应用)

MapArea 应该是存储了应用的每个 section 的 virtual page number

## 内存分配器的粒度

例如 BuddyByteAllocator 和 SlabByteAllocator 是基于 byte 为粒度

BitmapPageAllocator 是基于 page 为粒度

## TLB 没命中会怎样
先去内存页表找，页表也没有的话就触发缺页中断
