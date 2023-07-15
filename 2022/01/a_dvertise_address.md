# [advertise_address](/2022/01/a_dvertise_address.md)

常见于 etcd, docker-runner 配置中，表示客户端连接要用域名

服务端 bind 一般是 0.0.0.0 或者 `[::]` dual stack(both ipv4 0.0.0.0 and ipv6 ::)

例如 listen_address 可以是 `0.0.0.0:2379` 或者 `[::]:2379`

然后 advertise_address 给客户端连接用的地址，一般是服务端在的默认网卡(/proc/net/route)的 IP 地址

例如 192.168.1.101:2379

## advertise_address 的 default 值

可以看我 beginning_linux_programming repo 的

examples/get_default_route_ip_and_mac.rs 文件有详细介绍

1. 解析 /proc/net/route 获取 default_network_interface
2. 解析 /sys/class/net/{default_network_interface}/address

(本文由于文件名带 advertise 后缀导致被我广告拦截器屏蔽掉了...)
