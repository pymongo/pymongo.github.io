# [/proc/swaps](2021/12/proc_swaps.md)

看 k8s 安装的文章时说推荐把集群所有机器的 swap 关掉

swapoff 命令内部好像借助 /proc/swaps 实现

(又掌握了一个 /proc 的知识)
