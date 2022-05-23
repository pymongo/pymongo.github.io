# [iftop iotop](/2022/04/iftop_iotop.md)

iftop 和 iotop 都是类似 htop/top 的 top-like 监控软件，iftop 是以网络出口域名为单位去监控网络流量

iotop 则是以进程为单位监控 io 进程使用

## docker iotop 报错

kubernetes/docker container 内使用 iotop 会报错 `OSError: Netlink error: No such file`

iotop 是通过内核的 taskstats 接口获取统计信息的。taskstats 是基于 generic netlink 实现的需要 net 内核 namespace

## nfs io?

iotop 不会显示 nfs ，nfs io 监控相关工具需要 nfsstat 或 nfsiostat
