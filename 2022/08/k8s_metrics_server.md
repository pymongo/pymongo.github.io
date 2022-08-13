# [k8s metrics server](/2022/08/k8s_metrics_server.md)

为了能让我的 kind/minikube 能用上 kubectl top pod 还是需要装一个 metrics-server

## metrics 镜像被墙

镜像被墙 pod ImagePullBackOff: docker pull gcr.azk8s.cn/metrics-server/metrics-server:v0.6.1

用阿里镜像: docker pull registry.cn-hangzhou.aliyuncs.com/google_containers/metrics-server:v0.6.1

> docker tag registry.cn-hangzhou.aliyuncs.com/google_containers/metrics-server:v0.6.1 k8s.gcr.io/metrics-server/metrics-server:v0.6.1

改 docker tag 并不好使，算了还是编辑 deployment 吧

由于 edit deploy 会使使用 gcr 和使用 aliyun 的两个镜像 pod 共存，

所以我还是选择先 delete 原来从谷歌 github 来的 metrics server deploy

kubectl delete deployment metrics-server

总算让 metrics-server pod running 了

## metrics 要跟 k8s 版本兼容

kubectl top pod 依然报错 get pod -A 说 metrics READY 0/1 于是 describe pod 去看

> Readiness probe failed: HTTP probe failed with statuscode: 500

看 logs 说 `"Failed probe" probe="metric-storage-ready" err="no metrics to serve`

我看了下公司的 k8s cluster 客户端服务端版本都是 1.19 或者 1.20 且 metrics 版本要兼容 k8s 版本

果然有人也提过 minikube 在 metrics 0.6.1 完全不能用的 bug: <https://github.com/kubernetes-sigs/metrics-server/issues/1031>

说是 0.6.2 下个发版就会修复，那我还是等 metrics 修复后也把我 kind 升级成 1.24 的 k8s 版本

于是我换成 0.5.2 依然不能用，源码编译 0.6.2 的镜像也不能用

## 调整 server 的参数

如此调整之后，经过两次 scape 抓数据的时间(40s * 2) pod running 跑了一百多秒后终于 running 了

```
# patch: https://github.com/kubernetes-sigs/metrics-server/issues/1056#issuecomment-1177458261
- --kubelet-insecure-tls
# patch: https://github.com/kubernetes-sigs/metrics-server/issues/1056#issuecomment-1177458261
- --metric-resolution=40s
```
