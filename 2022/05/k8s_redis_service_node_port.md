# [K8s redis NodePort](/2022/05/k8s_redis_service_node_port.md)

最近公司的 K8s 集群跑着跑着 redis 服务就挂了

kubectl get services 发现 redis 服务 type 是 NodePort

```
# kubectl -n app get services
redis NodePort 172.17.114.30  <none> 6379:30626/TCP 22m
```

一般的 service type 都是 clusterIp

NodePort type 有点像 **docker run --net=host** 使用 host 机器的网络

所以用户只要能访问我们 host IP 就能直接访问到 redis 了

## redis.conf configmap

redis.conf 做成 configmap 可以在外部修改(不放 /etc/redis.conf)

redis 数据这种有状态的一般放在 volume 日志就 kubectl logs 去看(实际上 docker logs 也是通过 volume 实现 pod/container 没了后日志或数据还在宿主机)
