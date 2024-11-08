# [aws EC2 部署FTP](/2024/11/aws_ec2_deploy_vsftpd.md)

由于 aws S3 的面板过于复杂我弄了半天我的bucket都是 403, 部署的minio api server外网访问不了

加上公司祖传代码从ftp下载文件居多，还是潜心弄好ftp算了，先不care vsftpd默认是不是明文传输密码

我 https://medium.com/tensult/configure-ftp-on-aws-ec2-85b5b56b9c94

首先 aws 网页 右上角选 region 切换东京/香港区域，然后找到EC2 instance点开详情

Security->edit Security groups

inbound rule 加上 FTP 服务器端口，再预留几十个端口用于 FTP 被动模式，毕竟国内网络都是 NAT，FTP server无法通过客户端IP建立第二个连接

```
[ec2-user@jup3 ~]$ sudo cat /etc/vsftpd/vsftpd.conf
listen=YES
listen_ipv6=NO
listen_port=2999
pasv_enable=YES
pasv_min_port=1024
pasv_max_port=1048
pasv_address=<your_ec2_public_ip>
chroot_local_user=YES
```

大概核心的配置就这些，客户端用 lftp
