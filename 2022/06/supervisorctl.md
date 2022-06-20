# [supervisorctl](/2022/06/supervisorctl.md)

supervisord/supervisorctl 是一个 python 守护进程脚本应用专注容器，功能对标 systemd/systemctl

由于容器内系统的 PID=1 是 docker 或 entrypoint 无法是 systemd 而且容器系统比较精简也无法运行 systemd

所以 supervisor 成为一个 container 运行多个进程的守护进程/进程编排的好工具，适用于例如 jager all-in-one 等场合

## 跟 systemd 的不同

- systemd 的 PID=1
- systemctl 的 --host 可以控制远程主机，跨机器进程编排
- systemctl 可以通过 cgroup 进行资源限制，supervisor 不行

## supervisor 配置示例

```
[program:app]
command=/bin/app
environment=RUST_LOG="info,sqlx=warn"
stdout_logfile=/var/log/app.log
redirect_stderr=true
stdout_logfile_maxbytes=100MB
stdout_logfile_backups=25
```

可以发现 supervisor 自带了日志压缩切割分卷功能，跟 journalctl 类似，默认的 autorestart 配置是进程异常退出会尝试 3 次重启

## dockerfile

```
RUN apt-get install -y supervisor
COPY app.conf /etc/supervisor/conf.d/
ENTRYPOINT ["supervisord", "-c", "/etc/supervisor/supervisord.conf", "--nodaemon"]
```

supervisord 的 nodaemon 参数就是不让后台执行/detach 否则作为 entrypoint 一下子就让镜像 complete 了

## 更新 pod 内 app 可执行文件

```
cargo b --bin app
scp target/debug/app server:/root

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
