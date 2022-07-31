# [k8s probe](/2022/07/k8s_probe.md)

大纲-关键词: supervisor, 定制 pod 存活检测

Reference: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/



一般一个容器就一个进程，进程挂容器挂会触发 k8s 自动重启 pod

但是在 supervisor 作为 container entrypoint 进程时去启动多个应用进程时，应用挂了不会重启 pod

这时候就需要定制 k8s 存活探针通过轮询 `supervisorctl status app` 如果应用不是 running 状态则 exit code 不是 0

```yaml
spec:
  containers:
  - name: app
    livenessProbe:
      exec:
        command:
        - supervisorctl
        - status
        - app
      # take delay before first probe
      initialDelaySeconds: 5
      periodSeconds: 5
```

> busybox

以 k8s 文档官方示例来说，为啥他们老喜欢用 busybox 作为 demo 镜像

busybox 作为一个多可执行文件合而为一的类似「多可执行文件路由器」，例如 busybox ls 就路由去 /bin/ls

在 Linux 内核 qemu 运行的时候也提到 busybox 工具

## probe 的请求方式

shell, HTTP, TCP socket, grpc health

## readinessProbe

readinessProbe 跟 livenessProbe 的区别是，readiness 存活检测失败之后，不会杀掉 pod 重启

而是按用户的定制逻辑去发通知之类的
