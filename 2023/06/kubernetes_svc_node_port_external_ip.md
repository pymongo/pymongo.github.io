# [慎用 svc 的 externalIp](/2023/06/kubernetes_svc_node_port_external_ip.md)

这篇文章里 [sidecar 掐断 redis 流量](/2023/06/istio_sidecar_block_redis_ftp_traffic.md)

我遇到了 ftp 连不上的问题，急眼了我在想直接把 ftp 的 svc 改成连 master 节点的宿主机上的 ftp

> give a example k8s service access master node port 21

```
kind: Service
  ports:
    - name: ftp
      port: 21
      targetPort: 21
  type: NodePort
  externalIPs:
    - <master-node-ip>
```

我相信的 gpt 的代码，结果改完后 api server lookup master ip 出现死循环导致连不上 K8s api server 只能请云服务商帮忙删掉错误配置的 ftp service

教训: svc 尽量不要用 NodePort 方式
