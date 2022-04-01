# [centos8 container sshd](/2022/03/centos8_container_sshd.md)

试试在一个精简版的 centos8 image 用于 k8s 某个 pod 的 container 启动 sshd

dnf install openssh-server

```
sh-4.4# sshd start
sshd re-exec requires execution with an absolute path

sh-4.4# /usr/sbin/sshd
Unable to load host key: /etc/ssh/ssh_host_rsa_key
Unable to load host key: /etc/ssh/ssh_host_ecdsa_key
Unable to load host key: /etc/ssh/ssh_host_ed25519_key
sshd: no hostkeys available -- exiting.
sh-4.4# ssh-keygen -A

nohup /usr/sbin/sshd -D &
```

容器的 centos 为了精简都没有集成 systemd, 好吧 centos7 image 还有 service 到 centos8 只能手动 /usr/sbin/sshd 启动 ssh 了

甚至连 passwd 都没

```
sh-4.4# passwd root
sh: passwd: command not found
sh-4.4# dnf install passwd
Last metadata expiration check: 0:16:01 ago on Thu Mar 31 11:08:38 2022.
Dependencies resolved.
```

排查了半天 /usr/sbin/sshd 启动后 publickey 认证失败，算了只能老老实实用密码登陆了
