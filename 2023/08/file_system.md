# [文件系统](/2023/08/file_system.md)

## 文件系统分类
磁盘文件系统、日志文件系统(数据重要性高，要求读写都是原子操作)、数据库文件系统(WinFS)、网络/分布式文件系统、特殊文件系统(管道)

Linux 通过加一层 VFS 抽象，抹平了所有文件系统的差异

root->volume_mount_point->dir->file->disk_io_block

## Linux 如何避免文件链接死循环
用传统图遍历算法开销太大，linux 直接设置一个文件链接跳转次数限制

ELOOP (Too many levels of symbolic links)

## 分布式文件系统中有没有必要用目录
基于路径的索引难以并行化或者分布式，可以考虑将分布式文件系统的磁盘布局设计成 kv 化便于一致性哈希

## 文件系统实现

### 连续分配
数组元素是 文件头元信息+文件数据 

顺序/随机读写性能最好，但是文件长度增长怎么处理？

缺点是内存碎片

### 链式
文件头包含了到第一块和下一块的指针

缺点是随机读写性能差、可靠性差一旦某个节点数据遭到损坏整个链表就断开了灾难性

细分下去还有显式和隐式，FAT 用的就是隐式

### 索引分配
文件头包含索引块指针和索引

缺点是小文件也要存储索引块，大文件索引麻烦

实际系统上是这三个分配算法结合使用

### 多级索引
例如 ext4，小文件一级索引就能查询到，大文件要多级索引间接查询效率慢

### inode/data bitmaps
文件系统 bitmap 存储了所有空闲的 inode/data_block 标志位

### 崩溃一致性问题
断电的时候，位图/inode/block 的修改能否原子的全部执行或者全都不执行

```
Q: ext4断电时如何保证原子性，同一文件的bitmap/block/inode的修改要么全部完成要么都不完成

ext4文件系统在设计上采取了一些策略来保证在断电等异常情况下的原子性。以下是一些常见的机制：

日志（Journaling）：ext4使用日志来记录文件系统的操作，包括对bitmap、block和inode的修改。这意味着每个操作都会被写入日志中，而不是直接修改文件系统结构。在重新启动后，文件系统可以根据日志的内容进行恢复，以确保修改的原子性。

事务组（Transaction Groups）：ext4将文件系统的操作分组为事务。每个事务组包含一组相关的操作，这些操作要么全部完成，要么都不完成。事务组的信息也被写入日志中，以确保在断电等情况下可以进行正确的恢复。

写入校验和（Write checksums）：在写入数据块之前，ext4会计算数据的校验和并将其写入日志。这样，在发生断电等情况下，文件系统可以根据校验和验证数据块的完整性，以避免数据损坏。

这些机制的结合确保了ext4文件系统在断电等异常情况下的原子性。通过使用日志记录修改操作、事务组的概念以及校验和等技术，ext4可以在重新启动后正确地恢复文件系统，保证同一文件的bitmap、block和inode的修改要么全部完成要么都不完成。
```

### ext4 写日志优化
只将 metadata(bitmap/inode) 写入日志，文件数据不写

### bad block check

fsck

> sudo badblocks -v /dev/nvme0n1p2

> sudo e2fsck -c /dev/nvme0n1p2

```
/dev/nvme0n1p2 is mounted.
e2fsck: Cannot continue, aborting.
```

### dumpe2fs/debugfs/smartctl 看元信息

> sudo dumpe2fs /dev/nvme0n1p2

```
Filesystem magic number:  0xEF53
Filesystem revision #:    1 (dynamic)
Filesystem features:      has_journal ext_attr resize_inode dir_index filetype needs_recovery extent 64bit flex_bg sparse_super large_file huge_file dir_nlink extra_isize metadata_csum
Inode count:              30507008
Block count:              122018696
Reserved block count:     6100934
Overhead clusters:        2195792
Free blocks:              15987268
Free inodes:              25330472
First block:              0
Block size:               4096
Fragment size:            4096
```

---

进程有进程的文件打开表，内核也有维护系统的文件打开表，多个文件打开了相同的文件会映射到同一个内核打开的文件表
操作系统需要记录每个进程每个 fd 的指针偏移量

## rcore easy-fs layout
1. superblock(contains magic bytes、total inode/data blocks)
2. free_inode_bitmap
3. inode
4. free_data_block_bitmap
5. data_block

文件大小低于 28*512(block size) 的通过直接索引，更大的文件用一级索引(INODE_INDIRECT1_COUNT)和二级索引,

1. 磁盘块设备接口层: trait block_dev::BlockDevice, qemu virtual_device impl 在 os 或者是 fuse 中
2. 块缓存层: block_cache, rcore 实验中缓存淘汰算法是固定长度的队列，队列满的时候，遍历找到第一个未被进程占用的块(强引用计数为一)替换掉，如果所有块都被进程占用就 panic (所以队列长度要足够长超过所有进程预计占用块总和)

在较新版本的Linux内核中，pdflush的功能已经由pdflush进程改为由内核线程来执行，其中包括kworker线程和flush线程。这些线程会根据需要将脏数据写入磁盘，以保证数据的一致性和持久性。

## fs fuse

```rust
struct BlockFile(Mutex<File>);

impl BlockDevice for BlockFile
```

测试的时候可以用宿主机/开发机环境，用标准库的 File "模拟"出一个块状设备实现 BlockDevice trait

---

每个硬件设备一般都有一个唯一的IRQ号，用于标识该设备的中断请求。内核维护一个IRQ向量表（IRQ Vector Table），用于保存每个IRQ号对应的中断处理程序

---

```
Linux默认的磁盘调度算法是CFQ（Completely Fair Queuing）。
CFQ算法根据进程的I/O请求将其排入合适的队列，并按照公平原则进行服务。它通过将I/O请求合理地分配到不同的进程队列中，以确保每个进程都能获得公平的磁盘访问时间。这种算法适用于大多数常见的工作负载，并且在各种I/O负载之间提供了相对公平的性能。

然而，随着SSD（固态硬盘）等新型存储技术的发展，Linux内核也引入了一些新的磁盘调度算法，如Deadline和BFQ（Budget Fair Queueing）。Deadline调度算法更关注I/O请求的响应时间，而BFQ算法则更注重保证低延迟和预测性能。这些算法可以根据实际情况进行选择和配置，以满足不同的应用需求。
```
