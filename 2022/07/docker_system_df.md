# [docker system df](/2022/07/docker_system_df.md)

docker build 一个 nvidia 10+G 的镜像在运行 apt get  报错:

> #12 32.34 E: You don't have enough free space in /var/cache/apt/archives/

我看我硬盘还有 100+G 怎么会提示硬盘满呢？原来 docker 自身预分配/挂载了自己的硬盘分区去存缓存和镜像

用 **docker systemd df** 命令就可以查看 docker 自身存储空间的使用情况

```
$ docker system df
TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
Images          28        2         35.68GB   32.22GB (90%)
Containers      2         2         3.748MB   0B (0%)
Local Volumes   83        1         3.904GB   1.974GB (50%)
Build Cache     168       0         915.1MB   915.1MB
```

我用两个 docker prune 的命令清理一些 docker 硬盘使用

docker system prune
docker builder prune -a

网上说 docker d 可以加参数定制存储空间大小:

/usr/lib/systemd/system/docker.service

> ExecStart=/usr/bin/dockerd -H fd:// --storage-opt dm.basesize=50G

或者 `"storage-opt": [ "dm.basesize=60G" ]` 加到 /etc/docker/daemon.json

但我改了设置后依然不管用，docker build 一个大镜像依然提示 no enough space
