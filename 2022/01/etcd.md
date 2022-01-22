# [etcd](2022/01/etcd.md)

etcd 是基于 Raft 实现分布式一致性的 KV 数据库，k8s 的就是基于 etcd 实现

## Install/Deploy etcd

安装 etcd 可通过 aur 的 etcd-bin 或者 snap install etcd

`systemctl start etcd` 会启动 etcd 单实例版端口在 2379

## etcd compare to redis

|etcdctl|redis-cli|
|---|---|
|get --prefix ""|keys *|
|del --prefix ""|del *|

## etcd MVCC

etcd 相比 redis 有个额外的功能是 MVCC(Multi Version Concurrency Control) 以及相应的 revision/compact 的概念

所以删掉所有 KV 对并不会释放所有 etcd 的存储空间，因为还有以前版本的数据在存储中

## etcd 存储空间暴涨

原因是应用没有配置 etcd 的 auto-compaction 导致应用运行几小时后超过 etcd 默认的 2G 存储空间

这种通常都是日志打得太频繁导致存储空间满了

patch 就是加了 ETCD_AUTO_COMPACTION_RETENTION=1 并去掉了心跳日志存储到 etcd 和降低了心跳的频率
