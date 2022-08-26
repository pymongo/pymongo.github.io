# [NFS fifo file](/2022/06/nfs_fifo_pipe.md)

fifo 管道文件在 NFS 上
pod1 和 pod2 是同一个用户 root 则可以使用管道文件通信
如果两个机器的用户名(uid)不同则双方都感知不到对方已打开管道文件导致持续 block 卡住

网上说 NFS 没实现文件系统的部分功能，即便管道文件在 NFS 能跨机器通信也有很多 bug，
再且管道只是 IPC 也不建议跨机器通信

https://twitter.com/ospopen/status/1539927620678479872

纠错，两个机器 mount 同一个 NFS 只有都用 root 用户才能用 fifo 管道文件通信，用其他用户都不行

我在两个机器分别创建一个 用户名/uid/gid 完全一样的用户，都不能跨机器用管道文件通信

## pod/container mount

container mount 宿主机 /dev 下的一块固态硬盘设备是独占的，mount 之后其它 pod/container 不能 mount 这个设备

但如果是 mount 文件夹则可以共享，多个 pod/container 可以 mount 宿主机的同一个文件夹

这样情况下多个 pod/container 和宿主机走管道文件通信 IPC 是 ok 的

## 为什么要 NFS 是因为跨机器

因为公司的 K8s 集群有多个节点跨机器的，只能通过 NFS 共享文件了

## unix socket 也不能放 NFS

unix socket 状态信息是存在内核的，反正跨机器连接会 connection refused 无法感知对方机器已经 bind 该 socket
