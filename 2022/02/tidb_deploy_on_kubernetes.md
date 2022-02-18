# [TiDB Kubernetes](/2022/02/tidb_deploy_on_kubernetes.md)

## term

- kind: kubernetes in docker
- CRD: custom resource define
- ingress: 

## minikube, kind

kubectl, minikube, kind 这些安装过程就不记录了，太简单不值得浪费文字去记录

检查 minikube start 是否成功

> minikube kubectl cluster-info

```
Kubernetes control plane is running at https://192.168.49.2:8443
CoreDNS is running at https://192.168.49.2:8443/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'
```

试试装 tidb-operator

```
[w@ww ~]$ minikube kubectl -- apply -f https://raw.githubusercontent.com/pingcap/tidb-operator/v1.2.4/manifests/crd.yaml
unable to recognize "https://raw.githubusercontent.com/pingcap/tidb-operator/v1.2.4/manifests/crd.yaml": no matches for kind "CustomResourceDefinition" in version "apiextensions.k8s.io/v1beta1"
unable to recognize "https://raw.githubusercontent.com/pingcap/tidb-operator/v1.2.4/manifests/crd.yaml": no matches for kind "CustomResourceDefinition" in version "apiextensions.k8s.io/v1beta1"
```

minikube 的 kubectl apply 直接报错，先换 kind 试试

## kind

需要一个好一点的代理，否则 docker pull 下载镜像容易各种网络错

```
[w@ww ~]$ kind create cluster
Creating cluster "kind" ...
 ✓ Ensuring node image (kindest/node:v1.21.1) 🖼 
 ✓ Preparing nodes 📦  
 ✓ Writing configuration 📜 
 ✓ Starting control-plane 🕹️ 
 ✓ Installing CNI 🔌 
 ✓ Installing StorageClass 💾 
Set kubectl context to "kind-kind"
You can now use your cluster with:

kubectl cluster-info --context kind-kind
```
