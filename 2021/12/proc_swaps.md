# [/proc/swaps](2021/12/proc_swaps.md)

看 K8s 安装的文章时说推荐把集群所有机器的 swap 关掉

swapoff 命令内部好像借助 /proc/swaps 实现

(又掌握了一个 /proc 的知识)

但是 swapoff 只能禁用当前登陆环境的 swap 配置，重启后还是恢复先前配置

mount -a 可以模拟重启后重新挂载的配置，会发现 `swapoff -a` 并不生效

要想彻底干掉 swap 只能修改 /etc/fstab

但是在 fedora 35+ 高版本的 swap 好像不是通过分区实现的

> Fedora uses in-memory swap, not uses file or partition-based swap anymore

https://fedoraproject.org/wiki/QA:Testcase_SwapOnZRAM_disable

```
[w@fedora ~]$ swapon -s
Filename                                Type            Size            Used            Priority
/dev/zram0                              partition       8388604         0               100
[w@fedora ~]$ zramctl
NAME       ALGORITHM DISKSIZE DATA COMPR TOTAL STREAMS MOUNTPOINT
/dev/zram0 lzo-rle         8G   4K   80B   12K      12 [SWAP]
```
