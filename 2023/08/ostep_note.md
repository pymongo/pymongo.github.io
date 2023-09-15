# [OSTEP 笔记](/2023/08/ostep_note.md)

进程调度性能指标: 周转时间(任务完成时间-任务进入队列时间)、公平性

STCF(Shortest Time-to-Completion First)=PSJF(Preemptive Shortest Job First)，解决 SJF 因长时间任务在前面阻塞后面短时间任务执行，长时间任务执行中的时候会被短时间任务抢占

不确定的状态随机数，并发程序的形式语义

缓存亲和性，一个进程最好调度在同一个 CPU 上执行充分利用缓存，同理 K8s 节点亲和性也是想着让 pod 调度在同一个节点执行

连续的内存分配 malloc/free 返回的指针地址没有长度信息，有个解决办法是，内存分配器让 ptr-4 这段区域设置成分配区域大小(但是指针越界写错这段数值就完了)

由于每个进程的虚拟地址映射都不同，如何避免进程上下文切换的时候两个进程同样的 VPN 实际是不同物理地址。方案一进程切换的时候清空 TLB 方案二切换的时候修改 PageTableBaseRegister，方案三每个进程的 Address Space ID 不同

TLB miss 导致 RAM 并不是访问 RAM 的随机任意部位都一样快

> 数据库适合更大页使 TLB 有效覆盖率提高

```
当访问TLB（转换后备缓冲器）成为CPU流水线的瓶颈时，可以采取以下措施来解决这个问题：

增加TLB的大小：TLB是一个快速缓存，用于存储虚拟内存地址到物理内存地址的映射。通过增加TLB的大小，可以提高TLB的命中率，减少TLB访问的次数。这可以通过调整CPU硬件的设计参数或者在操作系统中配置TLB大小来实现。

提高TLB的访问效率：TLB的访问效率对于CPU流水线性能至关重要。优化TLB的访问效率可以通过使用更快的TLB芯片、增加更高级别的缓存层次结构等方式来实现。

增加TLB的并行性：TLB的访问通常是一个串行的过程，一个访问完成后才能进行下一个访问。通过增加TLB的并行性，可以同时处理多个TLB访问请求，从而提高吞吐量。这可以通过设计多个并行的TLB来实现，或者通过使用更高级别的多线程技术来处理并发访问。

使用更高级的地址转换技术：除了TLB，还可以考虑使用更高级别的地址转换技术来减少对TLB的访问。例如，可以使用快表（Translation Lookaside Buffer，TLB）或者分段、分页技术来减少对TLB的依赖。

优化程序访存模式：优化程序的访存模式可以减少对TLB的访问。例如，可以通过局部性原理来提高程序的局部性，从而减少对TLB的访问次数。
```

三种 cache miss:
- compulsory miss: 强制性未命中，缓存一开始为空被迫未命中
- capacity miss: 缓存容量满了需要替换置换一个旧的缓存
- conflict miss: 多个不同的缓存 key 映射到同一个缓存位置

LRU 具有 stack property, 加大缓存容量不会出现 Belady 问题，而 FIFO/random 会出现容量增大反而命中率下降的问题

riscv 比 x86 lock 更聪明的办法?

x86 是 lock 一个变量 m 之后，通过总线通知所有其他 CPU 核心或者其他 CPU socket 的缓存中的变量 m 要清除，开销很大

riscv 做法是 load_reserved/store_conditional

lr 指令让缓存打个 reserved 标记，然后处理器一继续拿这个数据去计算，如果其他处理器用了 sc 指令则会清除这个标记，

等处理器一计算完发现标记没了，就会重新读取一次变量 m 再重新计算(有点像 compare_and_swap)，在计算量很小的场合下这种策略确实比 x86 性能好(jyy 说 ARM/RISC-V 这样弱内存原子序的各个处理器之间简直就像一个分布式系统)

死锁解决办法，最完美的解决办法 total order 全序锁，按照顺序无环获取，但实现难，Linux 内存映射源码是 partial ordering 按照锁的地址从低到高或者从高到低加锁，例如加锁顺序 i_mmap_mutex, private_lock, swap_lock, mapping->tree_lock。死锁预防算法银行家算法，或者说两个互相依赖锁不让他们同时调度

基于事件的异步IO还有个问题是发生缺页的时候不可避免的阻塞

RAID 需要额外的控制器硬件支持(包含处理器内存等),我感觉用树莓派做 RAID 控制器是个不错的选择

RAID0 类似分布式一致性哈希，对 key 取模决定映射到哪个硬盘上

fsync 不一定会立刻刷硬盘，如果文件没创建的话? 要把文件的父目录也 fsync 才会刷盘

创建文件至少要很多次 IO 最简单的创建 /foo
1. read inode bitmap to find empty inode
2. write 1 to empty inode
3. read root directory
create_time/update_time update...

因此文件夹层数越多性能越差，一个文件夹内文件数量过多性能也越差(要建立多级索引)

## 分布式丢包问题
如果同时过多数据包到达，路由器的内存可能无法容纳所有数据包，唯一的选择是路由器主动丢包，同样的事情也发生在主机上

所以说丢包是网络的基本现象，那样要如何处理丢包呢？

## NFS

NFSv2 设计成无状态每次客户端请求都包含完整信息，服务端不会用客户端的 fd 入参，而是用 volume+inode+GenerationNumber(世代号) 去唯一的标识一个文件，例如客户端发来 fd=5 后来进程重启了 fd 变成 3 实际上是同一个文件，但 NFS 肯定不会参考客户端的 fd

正因为 NFS 设计成无状态和 fd 无关性，所以 **close(fd) 不需要跟服务端通信**

## NFS 缓存一致性问题
NFSv2 的解决是客户端 flush-on-close 和频繁 GETATTR 请求获取文件修改时间

为了避免频繁 rpc 请求获取文件修改时间，NFS 客户端给文件属性元信息加了三秒的过期失效