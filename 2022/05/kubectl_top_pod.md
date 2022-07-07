# [kubectl top pod](/2022/05/kubectl_top_pod.md)

top pod + pod_name 或者 + namespace

```
# kubectl top pod idp-develop-b-executor-5b87fdc98d-jstsz
NAME                                      CPU(cores)   MEMORY(bytes)   
idp-develop-b-executor-5b87fdc98d-jstsz   5m           1155Mi  
```

- /sys/fs/cgroup/memory/memory.usage_in_bytes
- /sys/fs/cgroup/cpu/cpuacct.usage
- man 2 getrusage

Reference: <https://stackoverflow.com/questions/54531646/checking-kubernetes-pod-cpu-and-memory>
