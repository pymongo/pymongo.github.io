# [ssh forward remote db](/2021/06/ssh_tunnel_forward_remote_db_port.md)

- `ssh -R`: map localhost's port to remote_server
- `ssh -L`: map remote_server's port to localhost

## 用datagrip浏览服务器上的数据

由于业界处于安全考虑一般生产服务器的数据库的端口都不会对外开放

最多在iptable防火墙上设置成在阿里云内网内开放，方便公司内网上其他机器访问

但是在bash上访问mongodb/MySQL之类的命令行客户端非常不方便浏览数据，偶尔看看还行远不如datagrip方便

我们可以借助SSH的22端口作隧道，将远程服务器的端口映射到localhost这样就能让本地的datagrip或mongodb compass浏览数据了

> ssh -N -L 27777:127.0.0.1:27017 centos@remote_server

-N 表示**仅转发**，不进行 ssh login

建议本地用「只读权限」的数据库帐号去浏览数据
