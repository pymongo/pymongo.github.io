# [rename cross fs](/2022/07/rename_errno_18_invalid_cross_device_link.md)

```
https://twitter.com/ospopen/status/1552235049583779846

tokio::fs::rename 报错 Invalid cross device link

原来 rename 系统调用会先 link(src, dst) 再 unlink(src)

报错来自 link 系统调用: 两个 link 指向同一个 inode 是不能跨设备/文件系统的
我将本机文件重命名到 NFS 上就复现这个错

mv 命令能移动文件去 NFS 因为它内部会拷贝文件到目标设备
```

从 strace 去看 mv 也发现会先尝试调用 rename

rename 报错 errno 18 的时候再 stat 看 device_id 然后将文件拷贝到目标文件系统上作为的临时文件

然后再将临时文件 rename 成目标文件

例如 Python site-package 搜索路径既有本机路径又有 NFS 路径时，用 pip 安装包就也可能报错 EXDEV
