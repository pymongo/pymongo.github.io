# [get pod -A](/2022/07/kubectl_get_pod_all_namespace.md)

kubectl get pod -A 参数可以列出所有 namespace 的所有 pod

例如想看 istio 的 IP 或者某个 IP 属于那一个 pod 可以这么做

```
# kubectl get pod -A -o wide | grep 10.9.190.71
ns      idp-raycluster-b-1551869182279176192-ray-worker-type-bvhk4
```
