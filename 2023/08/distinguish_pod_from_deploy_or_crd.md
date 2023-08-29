# [分辨 CRD 和 deploy](/2023/08/distinguish_pod_from_deploy_or_crd.md)

有个 pod 删不掉，`delete --force` 不去等 graceful shutdown 删掉了但又重新拉起来了

查了下 deploy 也没有这个 pod 应该是某个 CRD(例如 volcano vcjob) 创建出来的 pod，问问 gpt 怎样分辨 pod 属于哪个 CRD 吧

```
kubectl describe pod <pod_name>命令获取有关Pod的详细信息。在输出中，你可以查找以下字段来判断：

OwnerReferences字段：如果Pod是通过Deployment创建的，你会看到一个OwnerReference指向相关的Deployment资源。
ManagedFields字段：如果Pod是通过CRD创建的，你会看到一个ManagedFields项指向相关的CRD资源。
```

我就说 ManagedFields 这个字段很熟悉 CRD 的 pod 里面都有怪不得，于是 describe pod 发现这个删不掉的 pod 有 ManagedFields 内容是 helmxxx

helm list -A 果然找到了这个 pod 的所属

题外话: helm 的模板语法其实跟 Golang 标准库的 text/template 或 html/template 差不多(想起我改同事的 gozero 模板生成 Rust 代码的~~痛苦~~经历)
