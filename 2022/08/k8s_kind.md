# [K8s kind](/2022/08/k8s_kind.md)

复盘下在 fedora 和 manajaro 单机开发机装 K8s 集群的过程

当初完全不懂 K8s 看 minikube 各种概念痛苦无比(例如 get cm 是 configmap)，摸熟公司 K8s 集群后再学就一览众山小了

最终发现 kind 的效果最好(docker restart=always能开机启动)，所以以后就用 kind 够了

## K8s 周边工具安装

kubectl 客户端命令行工具要加 google repo 源才能用，但谷歌源加上也被墙所以我用 snap install kubectl

kubeadm 是创建集群才用到的工具，平时学习用 kubectl 就够了

## minikube 体验

用 rpm 装的，minikube start 加上 docker-opt 也没法让 minikube 容器开机启动

```
[w@localhost ~]$ docker inspect minikube | grep Restart -A 3
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 206324,
--
        "RestartCount": 0,
        "Driver": "btrfs",
        "Platform": "linux",
        "MountLabel": "system_u:object_r:container_file_t:s0:c320,c1010",
--
            "RestartPolicy": {
                "Name": "no",
                "MaximumRetryCount": 0
            },
```

!> start 之后会写 api server 到 ~/.kube/config 让 kubectl 找到 server

怕 docker system prune 把 minikube 的 container+network 都删掉，除非它能开机启动

加一个 systemd service 专门去开机启动太麻烦，或者 docker update 让它开机启动，再看看 kind 吧

### minikube image mirror

minikube 启动的时候加上以下两个参数应该能缓解下谷歌镜像被墙的问题

> --image-repository=registry.cn-hangzhou.aliyuncs.com/google_containers

> --registry-mirror=https://registry.docker-cn.com

### minikube start on boot

> docker update --restart=always minikube

<https://stackoverflow.com/questions/30449313/how-do-i-make-a-docker-container-start-automatically-on-system-boot>

on-failure will not only restart the container on failure, but also at system boot

但是我不确定 minikube 的一些命令会不会把 container restart 参数改掉

## kind

直接用 go install 装真心比 minikube 下载 rpm 简单，后续升级也容易

> GOPROXY=https://goproxy.cn go install sigs.k8s.io/kind@latest

```
[w@localhost ~]$ docker inspect kind-control-plane | grep Restart -A 3
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 258173,
--
        "RestartCount": 0,
        "Driver": "btrfs",
        "Platform": "linux",
        "MountLabel": "system_u:object_r:container_file_t:s0:c452,c531",
--
            "RestartPolicy": {
                "Name": "on-failure",
                "MaximumRetryCount": 1
            },
```

用 docker events 去看 kind 开机启动的事件 `docker events --filter container=kind-control-plane --since=15m`

kind cluster-info:

```
[w@localhost ~]$ kubectl get cluster-info
error: the server doesn't have a resource type "cluster-info"

[w@localhost ~]$ kind get clusters
kind

# this is kind cluster API server port
[w@localhost ~]$ kubectl cluster-info
Kubernetes control plane is running at https://127.0.0.1:44039
CoreDNS is running at https://127.0.0.1:44039/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy
```

我更喜欢 kind 没有用 192 开头的虚拟 IP 作为 cluster api server

### kind load docker-image

如果 deployment pull 策略为 Never 则 kind 无法使用宿主机的镜像

所以 pod 会报错 ErrImageNeverPull 除非用 kind load docker-image 将宿主机镜像发给 kind 容器才能用
