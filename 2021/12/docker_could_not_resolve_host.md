# [docker - resolve host](2021/12/docker_could_not_resolve_host.md)

在 Dockerfile 里面运行 yum install 遇到了

```
Could not retrieve mirrorlist http://mirrorlist.centos.org/?release=7&arch=x86_64&repo=os&infra=container error was
14: curl#6 - "Could not resolve host: mirrorlist.centos.org; Unknown error"
```

但 centos.org 其实是**没有被墙的** 在物理机上也能访问

这种问题就是 docker container 的 DNS 问题

在 /etc/docker/daemon.json 中加上(国内网络别用谷歌的 DNS)

```
"dns" : [
    "119.29.29.29",
    "114.114.114.114"
]
```

然后 sudo systemctl restart docker 就能用了

**如果本机发生过 OpenVPN 网络切换，需要 restart docker 才能让 container 网络访问正常**
