# [k8s 自动部署坑点](/2022/03/k8s_deploy_docker_no_cache.md)

昨天有同事反馈我 gitlab CI 的 [k8s 自动部署] 怎么部署成功后代码版本还是旧的，

我再细看 CI 的日志发现【图中 Step 2/4 部分】用了「缓存」

明明 rust musl+alpine 编译出来的镜像就 17Mb 还走啥缓存导致 COPY 了旧版本可执行文件

docker --no-cache 禁用缓存后我写的 k8s 自动部署总算能凑合用

https://twitter.com/ospopen/status/1504319859341291521

## 怎么创建一个 k8s

## k8s 添加服务

首先我还不是特别熟悉 k8s deployment yaml 的格式，所以就复制了一份其他同事微服务的"祖传"yaml

然后改下 yaml 以下信息就行:
- 服务名称
- 镜像名称
- 端口号, volume(如果是有状态的服务)
- ingress, nginx 路由转发

当然不会写 volume 配置可以让有状态的部分直接连宿主机的数据库...

## k8s 服务连接宿主机数据库

先看看 docker run 是怎么解决的，可以用 --network host 使用宿主机网络但是 container bind 的端口会在宿主机上

例如 container bind 了 9090 那么 宿主机就不能 bind 9090 了

也能在数据库连接域名用 host.docker.internal 

k8s 服务的容器用宿主机默认网卡的 ip 例如 192.168.12.129 就能访问宿主机的数据库

## k8s 部署单服务更新

k8s 部署更新的方法很多啦，例如 `rollup update`, 改镜像 TAG, helm 包管理

我用的是最简单的流程:
1. 编译代码放入 alpine 镜像打成 my_app:latest 的 TAG
2. kubectl delete -f my_app.yaml
3. kubectl apply -f my_app.yaml

如果镜像发生更新但是 TAG 没变貌似只能这样部署更新

用 kubectl get pod --namespace product_1 会看到有两个 my_app 服务其中一个是 terminating 状态

## 调试与可观测性

调试办法: kubectl exec/logs 这两个子命令跟 docker 一样

只不过 alpine 没有 curl, bash 等工具(用 /bin/sh)，想知道应用版本我一般是 exec 进去 my_app --version 帮助调试

可执行文件要带上 clap version 参数以及 HTTP 接口加一个返回 version，再有个 rails 那样返回所有 HTTP 路由的接口

## k8s 部署走了的弯路

一开始有人说编译完镜像后是不是要 sleep 才能让 k8s 识别啥的，

我自己以为是 kubectl delete 之后要 sleep (典型的瞎搞乱猜)
