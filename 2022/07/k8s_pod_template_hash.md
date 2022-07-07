# [k8s template hash](/2022/07/k8s_pod_template_hash.md)

<https://stackoverflow.com/questions/69940393/whats-the-exact-reason-a-pod-template-hash-is-added-to-the-name-of-the-replicas>

```
> kubectl get pod | grep postgres
postgres-58697bd5d-djsph
```

例如上述 postgres pod 的名字中 58697bd5d 是 app template hash 后续的 djsph 是 replica 副本的 hash

kubectl get deployments/rs 分别能获取到 app 名字以及副本数

get pod 加上 show-labels 的参数就能看到 app 的 template hash

```
> kubectl get pod --show-labels | grep postgres
postgres-58697bd5d-djsph                    1/1     Running             1          37d     app=postgres,pod-template-hash=58697bd5d
```

每次 delete pod 之后 hash 都会变，假设 postgres 只有一个副本如何才能获取这个带 hash 的 pod 名字呢?

## 获取 pod 名

用 grep+awk 的方法不太优雅，性能也慢

> kubectl get pods | grep postgres | awk '{print $1}'

用 selector 选中 app 为 postgres 之后再只选中 name 列就能直接通过 k8s API 拿到 pod name

```
> time kubectl get pod --selector=app=postgres -o custom-columns=:metadata.name --no-headers
postgres-58697bd5d-djsph

real    0m0.070s
user    0m0.071s
sys     0m0.017s
> time kubectl get pods | grep postgres | awk '{print $1}'
postgres-58697bd5d-djsph

real    0m0.101s
```

## api server

所有 kubectl 都会翻译成 k8s RESTFUL API 发给 k8s api server

kubectl 用 -v 参数就能看到实际请求的 json

```
> kubectl -v=999 get pod --selector=app=postgres -o custom-columns=:metadata.name --no-headers
I0707 20:25:38.700578  980608 loader.go:379] Config loaded from file:  /root/.kube/config
I0707 20:25:38.701345  980608 cached_discovery.go:114] returning cached discovery info from /root/.kube/cache/discovery/10.9.117.189_6443/servergroups.json
...
I0707 20:25:38.710239  980608 round_trippers.go:425] curl -k -v -XGET  -H "Accept: application/json" -H "User-Agent: kubectl/v1.20.6 (linux/amd64) kubernetes/8a62859" -H "Authorization: Bearer <masked>" 'https://10.9.117.189:6443/api/v1/namespaces/dp/pods?labelSelector=app%3Dpostgres&limit=500'
I0707 20:25:38.722325  980608 round_trippers.go:445] GET https://10.9.117.189:6443/api/v1/namespaces/dp/pods?labelSelector=app%3Dpostgres&limit=500 200 OK in 12 milliseconds
I0707 20:25:38.722348  980608 round_trippers.go:451] Response Headers:
I0707 20:25:38.722364  980608 round_trippers.go:454]     Cache-Control: no-cache, private
I0707 20:25:38.722375  980608 round_trippers.go:454]     Content-Type: application/json
I0707 20:25:38.722378  980608 round_trippers.go:454]     X-Kubernetes-Pf-Flowschema-Uid: fef97d51-74d7-4a30-9ca4-73bab5efc46f
I0707 20:25:38.722386  980608 round_trippers.go:454]     X-Kubernetes-Pf-Prioritylevel-Uid: 1acf452f-a07b-4a6f-85f8-c97e4b56dd48
I0707 20:25:38.722396  980608 round_trippers.go:454]     Date: Thu, 07 Jul 2022 12:25:38 GMT
I0707 20:25:38.722485  980608 request.go:1107] Response Body: {"kind":"PodList","apiVersion":"v1","metadata":{"resourceVersion":"71815228"},"items":[{"metadata":{"name":"postgres-58697bd5d-djsph",
...
postgres-58697bd5d-djsph
```
