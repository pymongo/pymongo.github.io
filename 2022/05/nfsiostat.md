# [nfs iowait](/2022/05/nfsiostat.md)

最近发现公司项目上了 NFS 之后(用于分布式多个 pod 通信嘛，例如所有 pod mount 一个 persist_volume by NFS 然后里面就可以放 .sock 文件用于通信了)

但是 NFS 毕竟读写慢，读单个大文件还不会比 ssd 慢很多，当读取琐碎的小文件频繁的时候例如 pip list 操作就慢的离谱了

当然 ssd 上面读大量小文件例如 pip list 也是要 2s 左右吧，但是到了 NFS 就足足要 25s

也就很多 IO 都在等待, iowait?

## iowait

/proc/stat 第一行的第五个数值就是当前的 iowait

也可以装 sysstat 用 iostat 去看

## nfsiostat

由于 iotop 看不到 nfs 还需要安装 nfs-common 包获取 nfs 监控工具

监控工具发现 pip list 中查询的 site-packages 大约 3000 个小文件，然后读取速度只有几百 kb/s 每秒处理读请求 400 次

难怪 NFS 上跑个 pip list 都要 8s+

## 共享文件存储

NFS 虽然慢但毕竟 Linux only 得到内核级别支持性能算是几个共享文件存储服务中最好了，性能远比 samba 强

FTP,CIFS/samba,NFS,OSS(s3/minio) 还有就是厂商自研的闭源分布式文件系统例如 ucloud 的 ufs

## s3 不能被两台机器 mount

由于 k8s 对内核 namespace 隔离限制，pod 1 mount 了 s3 bucket1 之后另一个 pod 就看不到 s3 的文件了

即便 mount point 在 NFS 上其它 pod 也就只能看到 pod 1 的 s3 bucket1 文件夹看不到任何文件，文件夹都是空的

这个问题貌似挺无解的，云产商提供的存储服务例如 NFS 这种只是给你存储 API 背后的 NFS/S3 server 对用户是不可见的

解决方法好像只能是 pod1 作为 s3 server 其它 pod 作为 client mount 进来就好

---

我们项目现在的做法是两个 pod 都挂载一次 s3 但是里面的文件内容是隔离的只对 pod 自身的系统可见
