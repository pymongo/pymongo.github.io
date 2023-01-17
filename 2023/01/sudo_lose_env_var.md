# [sudo 丢环境变量](/2023/01/sudo_lose_env_var.md)

发现 pod/container 的 entrypoint 用 sudo 启动应用进程会少环境变量(例如 K8s 自动注入的 REDIS_SVC_HOST)，要么就不用 sudo 要么就用 sudo -E 去携带

```
sudo printenv | wc -l
27
sudo -E printenv | wc -l
101
printenv | wc -l
97
```
