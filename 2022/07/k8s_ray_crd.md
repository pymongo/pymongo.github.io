# [K8s ray crd](/2022/07/k8s_ray_crd.md)

最近工作上用 ray 的 helm charts 在 K8s 集群中装了个 operator, 学习下如何使用

## Resource Type

k8s 自带的 [Resource](https://kubernetes.io/docs/reference/kubectl/#resource-types) 有 pod,rs,svc,node,events,deploy 等等

所谓 crd CustomResourceDefine 就是扩展 K8s 内置的 resource type

例如 `kubectl get raycluster`

```
# kubectl get raycluster
NAME                      STATUS    RESTARTS   AGE
idp-raycluster-b-global   Running   1          10m
t-12345                   Running   0          7d5h
t-1531263673594372096     Running   25         16d
t-1537032634283712512     Running   2          11d

# kubectl delete raycluster t-12345
raycluster.cluster.ray.io "t-12345" deleted
```

一般习惯上 raycluster 类型资源的 pod 的一些配置都在 metatada.labels 中

所以可以通过 selector 获取某个 raycluster 的 pod 可以这么写:

> kubectl -n dp get pod -l ray-node-name=ray-idp-raycluster-b-global-head -o custom-columns=:metadata.name --no-headers

## K8s operator

提到 crd 就不得不提 operator, 在 ray 这个应用中 operator 是负责动态创建 ray 集群以及调度(dispatch) 的 pod
