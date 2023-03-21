# [Linux RCU](/2023/03/linux_read_copy_update.md)

Rust Atomics And Locks 书中 Foreword(序言，一般都是请业界大佬写篇书评/作序) 提到了 RCU

RCU = read-copy-update 有点像 copy-on-write 读的时候共享引用读，写的时候复制一份

但 RCU 跟 COW 的区别是，RCU 复制一份修改完后再替换原数据，而 COW 用于进程 fork 这样写时复制之后就成子进程独立的数据

## RCU 的应用

Beginning Linux Programming 书中修改配置文件都是 cp 一份然后修改完之后 mv 回去，避免配置文件修改到一半的时候读取到不完整的配置

同理写超大 json 到硬盘，如果写到一半进程就 OOM 就导致例如只写了半个花括号的 json 到文件里，将原文件毁坏掉了

## Linux 源码

- Documentation/RCU/
- include/linux/rculist.h

Linux RCU 主要是用于链表，RCU 操作加个读写锁去保护数据安全

摘抄部分 gpt 给出的解答

> grace periods, which provides a window of time for which all old references to data to expire before they can be freed

> During the grace period, RCU ensures that no other threads are accessing a data structure before freeing the memory for it

Reference: <https://cloud.tencent.com/developer/article/1054094>, <https://cloud.tencent.com/developer/article/1006204>
