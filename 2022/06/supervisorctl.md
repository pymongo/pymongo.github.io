# [supervisorctl](/2022/06/supervisorctl.md)

supervisord/supervisorctl 是一个 python 守护进程脚本应用专注容器，功能对标 systemd/systemctl

由于容器内系统的 PID=1 是 docker 或 entrypoint 无法是 systemd 而且容器系统比较精简也无法运行 systemd

所以 supervisor 成为一个 container 运行多个进程的守护进程/进程编排的好工具，适用于例如 jager all-in-one 等场合

---

## 跟 systemd 的异同

systemd 的 PID=1, supervisor 一般设为容器 init 进程(例如 kind 镜像),

systemd/supervisor 都有相似的 restart/reload 命令，systemd 的 reload 命令需要手动设置 service 的 reload 回调，一般是发一个 SIGHUP 信号重载进程的配置，而 supervisor reload 更多是重载 service 配置而非应用进程配置

- systemctl 的 --host 可以控制远程主机，跨机器进程编排
- systemctl 可以通过 cgroup 进行资源限制，supervisor 不行

## supervisor relaod config

```
supervisorctl reread && supervisorctl update

(base) ray@lz:/store/lz$ sudo supervisorctl reread
submitter: changed
(base) ray@lz:/store/lz$ sudo supervisorctl update
submitter: stopped
submitter: updated process group
```

## reaped unknown pid

> 2022-08-06 03:06:16,460 INFO reaped unknown pid 252 (terminated by SIGHUP)

偶然能看到 supervisor reaped 收割其它 PID

这个现象的意思是有个 PID 成孤儿进程了让 supervisor 去 waitpid()

我这边连续 bash --login 两次之后其中一个就成孤儿了就会复现这样的情况

---

## 日志切割分卷

```
[program:app]
command=/bin/app
environment=RUST_LOG="info,sqlx=warn"
stdout_logfile=/var/log/app.log
redirect_stderr=true
stdout_logfile_maxbytes=100MB
stdout_logfile_backups=25
```

可以发现 supervisor 自带了日志压缩切割分卷功能(类似 logrotated)，跟 journalctl 类似，默认的 autorestart 配置是进程异常退出会尝试 3 次重启

### 日志收集权限

如果 program:app 通过 app 用户去运行，是没有权限将日志写入 /var/log/app.log 的，

说明日志收集过程是 supervisor 先内部捕获进程 stdout 再转发/合并到 /var/log 中

---

## --nodaemon

```
RUN apt-get install -y supervisor
COPY app.conf /etc/supervisor/conf.d/
ENTRYPOINT ["supervisord", "-c", "/etc/supervisor/supervisord.conf", "--nodaemon"]
```

supervisord 的 nodaemon 参数就是不让后台执行/detach 否则作为 entrypoint 一下子就让镜像 complete 了

## 更新 pod 内可执行文件

```
cargo b --bin app
scp -C target/debug/app server:/root

ssh server <<'REMOTE_COMMAND'
set -exu
kubectl config set-context --current --namespace=app
for pod in app-1 app-2; do
    pod_name=$(kubectl get pods | grep $pod | awk '{print $1}')
    kubectl cp /root/app $pod_name:/opt/
    kubectl exec $pod_name -- supervisorctl restart app
done
REMOTE_COMMAND
```

## pod 存活探针

一般一个容器就一个进程，进程挂容器挂会触发 K8s 自动重启 pod

但是在 supervisor 作为 container entrypoint 进程时去启动多个应用进程时，应用挂了不会重启 pod

这时候就需要定制 K8s 存活探针通过轮询 `supervisorctl status app` 如果应用不是 running 状态则 exit code 不是 0

虽然 supervisor/systemd 默认会将挂掉的应用尝试重启 3 次，但 3 次都失败之后，可能还是重启 pod 让应用的前置依赖也重启下会解决问题
