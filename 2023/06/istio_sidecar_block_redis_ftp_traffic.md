# [sidecar 掐断 redis 流量](/2023/06/istio_sidecar_block_redis_ftp_traffic.md)

最近公司某个 Kubernetes namespace 突然连不上 ftp 和 redis，redis 一连上就关掉连接，ftp 则是卡在 connected

```
# redis-cli -h 10.9.108.168 ping
Error: Server closed the connection


# ftp 10.9.45.140
Connected to 10.9.45.140
```

tcpdump 去看一切正常流量也成功转发的相应 svc 的 pod 内

一样的 helm 部署到另一个 namespace 上有一切正常

diff 了两个环境的 deploy 和 namespace 区别发现 **sidecar container 掐断了流量**

我把问题 namespace 的 `istio-injection=enabled` 删掉后再重启 pod 终于 redis/ftp 访问总算恢复了
