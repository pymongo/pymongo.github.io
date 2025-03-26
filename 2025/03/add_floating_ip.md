# [jito多IP](/2025/03/add_floating_ip.md)

苦于网络拥堵时jito限频从TPS=5降低到1 -32097 Rate limit exceeded. Limit: 1 per second for txn requests

可以单机器绑多个IP 进而自建VPS 当然量化多延迟很敏感不希望虚拟机的开销

> probably the best option for your requirement of very fast VPS would be to rent a dedicated server with ryzen (7000 or 9000 series) cpu with high core clock frequency and install proxmox ve on the machine. There you could create vps machines as you need with proxmox ve.

hostkey/livingbot找不到买弹性IP 所以用hetzner演示, 由于aws太贵就不用 hz floating IP 类似于 aws 的弹性IP吧

首先hz的VPS一定会有一个 primary IP, 默认是一个ipv4(3€)和ipv6(1€)月租，创建的时候不要勾选ipv6 很多交易所绑IP或者很多服务例如jito,github不支持v6

after hz web floating ip assign to VPS

```
root@ok1:~# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 96:00:04:10:50:8b brd ff:ff:ff:ff:ff:ff
    altname enp1s0
    inet 192.168.200.162/32 brd 192.168.200.162 scope global dynamic eth0
       valid_lft 51907sec preferred_lft 51907sec
    inet6 fe80::9400:4ff:fe10:508b/64 scope link
       valid_lft forever preferred_lft forever
root@ok1:~# ip addr add 192.168.79.33 dev eth0
root@ok1:~# ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 96:00:04:10:50:8b brd ff:ff:ff:ff:ff:ff
    altname enp1s0
    inet 192.168.200.162/32 brd 192.168.200.162 scope global dynamic eth0
       valid_lft 51878sec preferred_lft 51878sec
    inet 192.168.79.33/32 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::9400:4ff:fe10:508b/64 scope link
       valid_lft forever preferred_lft forever
root@ok1:~# curl "https://checkip.amazonaws.com"
192.168.200.162
root@ok1:~# curl --interface 192.168.79.33 https://checkip.amazonaws.com
192.168.79.33
```

- golang `net.Dialer{LocalAddr: &net.TCPAddr{IP: net.ParseIP(sourceIP),}`
- rust reqwest::Client::builder().local_address(source_ip)

```c
struct sockaddr_in source_addr, dest_addr;
sockfd = socket(AF_INET, SOCK_STREAM, 0);
memset(&source_addr, 0, sizeof(source_addr));
source_addr.sin_family = AF_INET;
source_addr.sin_addr.s_addr = inet_addr(source_ip);
source_addr.sin_port = 0;  // Let OS choose port
bind(sockfd, (struct sockaddr*)&source_addr)
```
