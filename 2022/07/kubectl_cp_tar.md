# [kubectl cp 原理](/2022/07/kubectl_cp_tar.md)

用 kubectl cp 可执行文件准备更新 pod 内进程的时候遇到了报错

```
# kubectl -n app cp --no-preserve=true /root/kernel_manage raycluster-head-type-kx8sb:/usr/local/bin/
tar: kernel_manage: Cannot open: File exists
tar: Exiting with failure status due to previous errors
command terminated with exit code 2
# kubectl -n app cp --no-preserve=true /root/kernel_manage raycluster-head-type-kx8sb:/usr/bin/
tar: kernel_manage: Cannot open: Permission denied
tar: Exiting with failure status due to previous errors
command terminated with exit code 2
```

好奇 kubectl cp 为啥会有 tar 报错，原来 kubectl cp 基于 exec + tar 实现:

(毕竟 kubectl 通过 kube api server 实现，喜欢这样用尽量少的 API 实现多个功能例如 exec/cp 都是通过 exec API 实现)

```
kubectl cp --help
Copy files and directories to and from containers.

Examples:
  # !!!Important Note!!!
  # Requires that the 'tar' binary is present in your container
  # image.  If 'tar' is not present, 'kubectl cp' will fail.
  #
  # For advanced use cases, such as symlinks, wildcard expansion or
  # file mode preservation, consider using 'kubectl exec'.
  
  # Copy /tmp/foo local file to /tmp/bar in a remote pod in namespace <some-namespace>
  tar cf - /tmp/foo | kubectl exec -i -n <some-namespace> <some-pod> -- tar xf - -C /tmp/bar
```

由于 ray 的 pod 默认 USER 是 ray 没有 /usr/local/bin/ 和 /usr/bin 的权限所以 kubectl cp 会报错

解决办法是文件 kubectl cp 放 NFS 或者 /tmp 这种有权限的目录，然后再 sudo cp 到想要的 /usr/bin 目录
