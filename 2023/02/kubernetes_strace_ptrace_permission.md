# [K8s ptrace 权限](/2023/02/kubernetes_strace_ptrace_permission.md)

pod 内用 strace/gdb 发现没权限，需要加下权限方便调试应用

> strace: attach: ptrace(PTRACE_SEIZE, 289): Operation not permitted

docker: `docker run --cap-add=SYS_PTRACE`

kubernetes: `spec.containers.securityContext`

```yaml
securityContext:
    capabilities:
        add: [ "SYS_PTRACE" ]
```

或者加上 SYS_ADMIN 权限 ADMIN 权限等于启用所有 securityContext 选项包括 SYS_PTRACE

SYS_ADMIN 的权限太大了，可以让容器内看到物理机的真实进程 ID 或者绕开 GPU 卡数资源限制

`privileged: true` 等于所有 capabilities 都加上，下面配置其实就不用再加 SYS_ADMIN 了

```yaml
spec:
  containers:
  - args:
    - 'foo'
    command:
    - bash
    securityContext:
      capabilities:
        add:
        - SYS_ADMIN
      privileged: true
```
