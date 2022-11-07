# [helm install](/2022/10/helm_install_volcano.md)

```
sudo pacman -S helm
kubectl create namespace volcano-system
helm install helm/chart/volcano --namespace volcano-system --name volcano
Error: unknown flag: --name
```

helm v3 之后 helm install 后必须跟一个 name 的参数作为 3st 参数

> helm install volcano --namespace volcano-system helm/chart/volcano

但是报错 repo 找不到 `Error: INSTALLATION FAILED: repo helm not found`

添加 helm 官方 repo 并尝试搜索 volcano 包结果提示找不到

```
helm repo add stable https://charts.helm.sh/stable
helm search repo volcano
```

## 从源码安装 chart

所以 volcano 包可能没有在 helm 包中心里面，helm repo search nginx 是能找到好几个版本的，所以只好下载 volcano 源码再去安装源码里面的 helm chart 吧

```
git clone https://github.com/volcano-sh/volcano.git
cd volcano
cd installer
# read installer/README
helm install volcano --namespace volcano-system helm/chart/volcano

[w@ww installer]$ kubectl get pod -A | grep volcano
volcano-system       volcano-admission-69b486dbf5-5mdsg           1/1     Running     0             18h
volcano-system       volcano-admission-init-ls8dh                 0/1     Completed   0             18h
volcano-system       volcano-controllers-6869c78b5b-m6wx4         1/1     Running     0             18h
volcano-system       volcano-scheduler-5c7d8679b4-5m5fj           1/1     Running     0             18h

[w@ww installer]$ helm list --all-namespaces
NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART           APP VERSION
volcano volcano-system  1               2022-10-24 21:14:33.231083626 +0800 CST deployed        volcano-1.5     0.1 
```

## volcano concepts

- podGroup: e.g. spark cluster
