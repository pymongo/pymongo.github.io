# [kubectl VirtualService lstio](/2022/05/kubectl_get_vs_lstio.md)

## lstio VirtualService

kubectl get vs 和 kubectl get svc 所以有啥区别呢

根据 [k8s resource type 文档](https://kubernetes.io/docs/reference/kubectl/#resource-types)

其实并没有 get vs 类型，但我看同事在通过 get svc 和 get vs 排查某些服务 503 的问题

原来 VirtualService 是 lstio (一种服务网格)的概念

---

503 也可能是 endpoint 写错(kubectl describe vs 去看)导致 lstio/envoy 没转发请求
