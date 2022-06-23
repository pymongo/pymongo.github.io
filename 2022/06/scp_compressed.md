# [scp compressed](/2022/06/scp_compressed.md)

最近沉迷 scp && kubectl cp && supervisorctl restart 的 "热更新"(不重启 pod) 的部署

影响部署速度的最大问题是 scp 到 k8s 控制的云主机太慢了

本来想说本地 zip 一下再 scp，同事突然打断说用 scp 可以加上压缩参数

类似的 rsync 也能加上压缩的参数

scp 传文件加上压缩后，就跟 steam/battlenet 下载游戏是便下载边压缩/解压一样，下载速度等于 网速+解压速度

在我办公网络中下载上传速度是 5M/s 用 scp -C 之后成 23 M/s 用 battletnet 下载游戏是 33M/s
