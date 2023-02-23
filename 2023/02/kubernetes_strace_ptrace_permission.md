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
