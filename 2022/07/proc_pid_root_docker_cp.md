# [docker cp pid root](/2022/07/proc_pid_root_docker_cp.md)

<https://twitter.com/fuweid89/status/1552987134801616904>

推上有人分享除了 docker cp 可以拷文件到 container 也可直接复制文件到 `/proc/[pid]/root`

容器技术的几大基石: kernel_namespace(pid,net,mnt), cgroup, chroot

其中 chroot 能让 container 拥有独立的隔离的文件系统

根据 proc 的 man 文档的 `/proc/[pid]/root` 章节: <https://man7.org/linux/man-pages/man5/proc.5.html>

> This file is a symbolic link that points to the process's root directory

## docker top

docker ps

```
CONTAINER ID   IMAGE                  COMMAND                  CREATED        STATUS        PORTS                                       NAMES
a4875dcba7cb   note                   "supervisord --nodae…"   20 hours ago   Up 20 hours   0.0.0.0:3003->3000/tcp, :::3003->3000/tcp   note
c66b6bc58b71   kindest/node:v1.21.1   "/usr/local/bin/entr…"   5 months ago   Up 3 days     127.0.0.1:37641->6443/tcp                   kind-control-plane
```

kindest 的 container 是通过 `docker run --restart=always` 类似 systemd service 的 restart: always 所以是开机启动的

我们想在宿主机看 note 容器内每个进程在宿主机的 PID 可以用 docker top container

```
UID                 PID                 PPID                C                   STIME               TTY                 TIME                CMD
root                1298131             1298110             0                   Jul31               ?                   00:00:10            /usr/bin/python3 /usr/bin/supervisord --nodaemon
root                1298236             1298131             0                   Jul31               ?                   00:00:31            redis-server *:6379
root                1298237             1298131             0                   Jul31               ?                   00:00:00            gateway
root                1298238             1298131             0                   Jul31               ?                   00:00:00            kernel_manage
root                1298239             1298131             0                   Jul31               ?                   00:00:00            lsp
root                1298240             1298131             0                   Jul31               ?                   00:00:03            python3 /usr/bin/remote_criu.py
root                1298241             1298131             0                   Jul31               ?                   00:00:00            note_storage
root                1298242             1298131             0                   Jul31               ?                   00:00:00            submitter
root                1298243             1298131             0                   Jul31               ?                   00:00:00            node src/server.js
root                1299805             1298110             0                   Jul31               pts/0               00:00:00            tail -f /var/log/kernel_manage.log
```

可以看到容器的 pid=1 进程是 supervisord 在物理机的 pid 是 1298131

```
$ cat /etc/os-release
NAME="Manjaro Linux"

$ sudo cat /proc/1298131/root/etc/os-release
NAME="Fedora Linux"
VERSION="36 (Container Image)"
ID=fedora
```

## docker cp 源码

docker cp 的原理我猜测跟 kubectl cp 一样是通过 docker exec 一个压缩包来实现的，让 cp 通过 exec 去实现只用一个 API 就够

<https://github.com/docker/cli/blob/f1615facb1ca44e4336ab20e621315fc2cfb845a/vendor/github.com/docker/docker/client/container_copy.go#L33>

docker cli 源码中 docker cp 最终包装成一个 RESTFUL API 给 docker engine server 发

(注意 docker-ce(社区版) 改名成 moby) TODO 我准备去 docker engine server 端看 cp 接口的逻辑
