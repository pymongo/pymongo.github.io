# [高性能服务器读书笔记 2](2021/07/linux_high_performance_server_programming_2.md)

## IP 协议简介

- IP 头部信息，src, dest, 指导 IP 分片和重组以及指定通信行为
- IP 数据包的路由和转发
- 无状态/无上下文: 无法处理乱序或重复的数据包

如果超时或 checksum 没通过则接收端会返回一个 ICMP 差错报文给发送端

### 何为乱序

例如第 N+1 个数据包到达后，第 N 个数据包还没到达

## IPv4 Header

- version : 4_bit, 4 or 6(IPv6)
- header_length: 4_bit, len's unit is u32, max is 15 * 4 = 60 bytes
- type_of_service/differentiated_services: 8_bit: 最小延时，最大吞吐量，最高可靠性和最小费用等设置，FTP 需要最大吞吐，SSH 需要最小延时
- total_length: u16, 由于 MTU 限制长度超过 MTU 需要分片传输
- ID: 数据包序号，初始值系统随机生成，每发一个数据包就+1 「同一个数据包所有分片都具有相同 ID」
- flags: DF==don't fragment; more_fragment 用于分片，同一个数据包除了最后一个分片的 more_fragment 是 0，其余分片都是 1
- fragment_offset: 可以暂时简单理解成 fragment 索引，类似数组下标
- TTL: 数据包到达接收端前「允许的最大路由跳(hop)数」，通常是 64，「用来避免路由拓扑图中有环，数据包陷入死循环」
- protocol: 可选值在 /etc/protocols，似乎是 socket 系统调用的一个参数
- header_checksum: u16, 使用 CRC 算法检测 IP 头部数据是否损坏
- src_ipv4: u32
- dest_ipv4: u32
- option: 变长可选字段，用于 记录路由(traceroute)、记时间戳等等功能

但是现在的 traceroute 命令用的是 UDP+ICMP 实现了更可靠的 路由记录，并没有完全用 IP 数据包的 option 字段

### IP 数据包分片

例如 ICMP 数据包长度 1501，则第二个分片中不会包含 ICMP 的头部信息，因为 内核 IP 模块重组分片时只需要一份 ICMP 头部信息

> sudo tcpdump -i lo -c 10 -w temp/tcpdump_icmp_1 icmp

由于 ping 127.0.0.1 会通过 lo 设备发数据包，但注意 lo 设备的 MTU 是 65536，所以 ping 127.0.0.1 -s 1501 看不出分片传输

## 「实验_3」观察 ping 数据包分段

1. sudo tcpdump icmp -c 6 -w temp/tcpdump_icmp_2

2. ping -s 1501 192.168.1.65

-s 参数表示设置 ping 数据包长度，设置成 1501 则一定会比 WiFi 的 MTU 长

### 实验记录

![](ping_request_fragment_1.png)

![](ping_request_fragment_2.png)

做完实验后，通过 fragment 2 的截图很好的理解了 fragment_offset 字段的含义

---

## 路由表

```
[w@ww ~]$ route
Kernel IP routing table
Destination     Gateway         Genmask         Flags Metric Ref    Use Iface
default         RT-AC86U-ADF8   0.0.0.0         UG    600    0        0 wlp4s0
172.17.0.0      0.0.0.0         255.255.0.0     U     0      0        0 docker0
192.168.1.0     0.0.0.0         255.255.255.0   U     600    0        0 wlp4s0
```

简单解释 route 命令的输出信息:
- Genmask: 网络掩码
- Flags: U: 该路由项是活动的, G: 该路由项的目标是网关, H: 该路由项的目标是主机
- Metric: 路由距离，到达指定网络所需的中转数

路由时现在 route 路由表查看目的地的 IP 地址，如果没有就选择默认路由项，让数据包的下一跳是路由器网关

ICMP 的重定向报文也能更新路由表的缓存

## route table update

router use BGP, RIP, OSPF ... protocol to discover new path and update route table

## Ipv6

Ipv6 不是对 Ipv4 的简单扩展，而是跟 v4 两个不同的数据包类型，而且 IP header, option 都不太一样

---

## TCP

TCP 是有状态的全双工一对一，UDP 更适合用于广播(例如接收聊天室消息推送)

因为 TCP 有缓冲区，所以 write/send 调用次数跟 TCP 报文数没有固定的数量关系

TCP 发出报文后要求对方应答，如果发出后超过一定时间没应答就会「超时重传」

### TCP header

[RFC 793](https://datatracker.ietf.org/doc/html/rfc793#section-3.1)

- src_port: u16, dest_port: u16
- sequence_number: u32 // 序号，解决网络传输包乱序问题
- acknowledgement_number: u32 // ack，解决丢包问题
- data_offset: u4,
- reserved: u6,
- /// flags.URG, Urgent Pointer
- /// flags.ACK,「重要」表示收到的 ack_num 有效，除了建连接第一个 SYN 可以不带 ACK, 其余 TCP 数据包必带 ACK
- /// flags.PSH(push), 告诉接收端应该立即从 TCP 缓冲区读取数据，为后续数据腾出空间
- /// flags.RST, 要求重新建立连接
- /// flags.SYN,「重要」要求建立连接，含 SYN 的叫同步报文, SYN aka synchronize
- /// flags.FIN,「重要」通知对方本端要关闭连接
- flags: u6, // URG(Urgent Pointer), , , , SYN()，
- window: u16, // TCP 流量控制，告诉对方本端 TCP 缓冲区剩余容量，让对方根据剩余容量控制发送速度
- checksum: u16, // CRC 算法校验 TCP 头部+数据部分
- urgent_pointer: u16, // 或者叫紧急偏移
- options: `Vec<Option>`

```rust
struct Option {
    kind: u8,
    /// include kind and length
    length: u8,
    info: variant
}
```

#### TCP options

###### SYN 必带选项 max_segment_size

SYN 建立连接的 TCP 数据包必定会设置上选项: kind=2, length=4

用来约定最大报文长度，一般设置成 1460 = 1500(MTU) - 20(TCP_header) - 20(IPv4_header)

###### SYNC 必带选项 window_scale

window_scale(窗口扩大因子)，在 kernel 的设置项 `/proc/sys/net/ipv4/tcp_window_scaling` 中默认是开启

window_scale 的取值范围是 0~14, 实际窗口大小则是 window << window_scale = window * 2.pow(window_scale)

###### SYNC 必带选项 SACK

kind=4, SACK aka Selective Acknowledgment

如果不开启 SACK，TCP 某个序号的报文丢失，则需要重传该序号往后的所有数据包，造成可能重复传数据包导致性能开销的问题

SACK 开启后只需要重传丢失序号的数据包

##### 重要选项 timestamp

kind=8, 用于计算 RTT(Round Trip Time) 通向双方的回路时间，作为拥塞控制的重要入参

### 三次握手建连接和 ack

例如 192.168.11.75 向 192.168.11.32 建立 TCP 连接

¶ 1. 192.168.11.75:35834(connect 方) -> 192.168.11.32:23(listen 方)

```rust
let init_seq_num_1 = 1814108379;
TcpHeader {
    seq_num: init_seq_num_1,
    ack_num: 0,
    flags: SYN
    // ...
}
```

¶ 2. 192.168.11.32:23 -> 192.168.11.75:35834

```rust
let init_seq_num_2 = 1796236373;
TcpHeader {
    seq_num: init_seq_num_2,
    ack_num: init_seq_num_1 + 1,
    flags: SYN | ACK
    // ...
}
```

¶ 3. 192.168.11.75:35834 -> 192.168.11.32:23

```rust
TcpHeader {
    seq_num: init_seq_num_1 + 1,
    ack_num: init_seq_num_2 + 1,
    flags: ACK
    // ...
}
```

server state change:
1. SYN_RCVD: receive client syn
2. ESTABLISHED: receive client ack

### 为什么建立连接要三次握手

双方都需要互相发一个 SYN，以及初始化各自的 seq_num

client connect() 后收到 server 返回的 SYN+ACK，client 端进入了 TCP 状态机的 ESTABLISHED 状态

然后 client 返回一个 ACK，server 收到后才能进入 ESTABLISHED 状态，这也是必须要握手 2 和 3 才能让 server 进入 ESTABLISHED 状态

### 三次握手怎么解决 SYN 防重入

三次握手还有一个原因是服务端防止客户端 SYN 重复发，防重入

例如 客户端连续发两个 SYN, 但是第一个 SYN 在网络中没丢包只是在三次握手后才到达

服务端返回 ACK, 但是客户端已经是 ESTABLISHED 状态不会回复，所以服务端不会重新建立连接

### 四次挥手断连接

1. A->B: FIN | ACK
2. B->A: ACK
3. B->A: FIN | ACK
4. A->B: ACK

由于 TCP 全双工，看上去实际上像是双方各发一个 FIN 两次，因为两次 ACK 都是被动回复的

因为收到 FIN 请求的一端，需要确认缓冲区没有数据要发送才会发一个 FIN，2MSL

#### shutdown() 半关闭状态

因为 TCP 是全双工的，允许两个方向独立的关闭，

先关闭方发 FIN 告诉对方本端已经完成数据传输且收到对方 ACK 后，本端允许接收对方发来的数据，这种状态叫关闭状态

所以所谓关闭连接「四次握手」，不一定是四次，有可能是 6 次，因为对方发 FIN 之前还能发数据

shutdown() 系统调用提供对半关闭的支持，记住 close() 则是进入全关闭状态

#### FIN_WAIT_2

主动关闭连接一方收不到对方的 FIN，FIN_WAIT_2 定时器在一定时间内收不到对方 ACK 就会让主动关闭方自行关闭

#### 主动关闭方 TIME-WAIT 状态

解释第四次挥手后主动关闭方为什么还要等待 2 MST(Maximum segment lifetime)

主动关闭方用 ACK 回复对方 FIN 后，等待的时间是 2 倍的数据包传递时间，

万一对方没收到 ACK ，被动方就会重新发 FIN，ACK 一来 FIN 一去正好 2 个 MSL

### 为什么要被动 ACK

建立连接后，一端发送 telnet 之后另一端一定会被动返回一个 ACK，导致一次单向的 telnet 数据通信走了两次 TCP

接收端 ACK 告诉发送端可以释放 TCP 缓冲区中刚刚发送的数据

### TCP SYN 超时

#### 实验? 用 iptables 过滤 SYN 数据包观察超时

三次握手中 第 2,3 次如果超时+超过最大重连次数就会关闭连接

如果 client/server 超过 tcp_syn_retries 次没回两边会断开连接

超时重连的间隔是: 1s, 2, 4, ... (倍增法)

### 第三方伪造 RST

由于 ISN 动态随机，第三方猜出 seq 难度很大

### SYN FLOOD 攻击

攻击者发送大量 SYN 服务器回 SYN ACK 但攻击者又不回 ACK

导致服务器大量资源用于 SYN_RECV 状态的连接中

解决 SYN FLOOD 攻击的方法:
- 减少 tcp_syn_retries 重连次数
- 调大 tcp_max_syn_backlog 参数
- SYN cookie 技术

### 三次握手第三次丢包怎么办

假设重试次数用完服务器关闭连接，但客户端不知道还在 ESTABLISHED 状态

等客户端发数据包时服务端回一个 RST 要求客户端重新建立连接

### 三次握手中能携带数据部分吗

1,2 次不行，避免 SYN FLOOD 攻击中携带大量数据

### connect() 时端口不存在会怎样

server 会返回一个 RST 且窗口大小为 0 然后 connect 调用失败

### connect() 时地址不存在会怎样

如果跟目标机器在一个网段，如果 ARP 缓存没有目标机器 IP，则不断发 ARP 直到超过最大重连次数

如果 ARP 缓存有目标机器，但是目标机器拔掉网线了，则重发且是 ARP 缓存删掉目标机器

如果目标机器在广域网另一个路由器网段中，则路由器不断转发 hop 数据包直到目标机器网段的路由器，ARP 请求对方路由器直到超过最大重连次数

### client 主动关闭时的状态变化

1. FIN_WAIT_1: send FIN
2. FIN_WAIT_2: receive ack
3. TIME_WAIT: receive server FIN, waiting 2 MST
4. CLOSED: after wait 2 MST

### server 被动关闭时的状态变化

1. CLOSE_WAIT: receive FIN
2. LAST_ACK: send FIN
3. CLOSED: receive ack

### 孤儿连接

主动关闭方 FIN_WAIT_2 未等对方 FIN 就提前关闭，此时连接由内核托管，称为孤儿连接

### netstat net 查看 TCP 状态

### 返回 RST 的几种可能
- connect() 端口不存在
- connect() 端口处于 TIME_WAIT 状态
- 建立连接后重复的 SYN 数据包
- 通过 socket 的 SO_LINGER 选项发送 RST
- 服务器主动关闭客户端却没收到 FIN 客户端发数据后会收到 RST

### TCP 交互数据流

用于数据量小但实时性要求高例如 SSH (IP header type_of_service 也有针对 ftp 和 SSH 用不同选项)

例如 ssh/telnet 登陆后输入 ls 命令，每输入一个字母都会发 TCP 数据包

此时服务端可能会延迟确认，例如等 ls 输入完了再批量 ACK

与交互数据流对应的成块数据则用于 FTP

### 紧急数据

不在缓冲区排队，直接被应用程序处理，术语叫 Out Of Band data，在 TCP 中是 urgent_pointer

其实并不是不排队，而是读到只有 1 byte 的一个带外缓冲区

## (TODO 待补课)拥塞控制+流量控制+滑动窗口

根据收发双方的缓冲区可用容量，调节数据包吞吐量，组成闭环反馈控制

类似蒸汽机的离心式调速器: <https://en.wikipedia.org/wiki/Centrifugal_governor>

当蒸汽流通快，会反馈让进气口变小，从而降低蒸汽速度，当蒸汽流通太慢时又开大进气口，从而让管道中的蒸汽速度趋于稳定

TCP 也是类似，数据包 RTT 小发的快，接收端缓冲区大，就发快点，反之数据包发慢点

### 滑动窗口

窗口大小就是无需等待对方应答，可以继续发送数据的最大值

TODO 书上讲这部分的概念我很难理解进去看进脑子，以后找时间专题突破这部分内容，该回头补课拥塞控制

### kernel 中 TCP 相关配置

- /proc/sys/net/ipv4/tcp_window_scaling: bool // 是否开启 window scale
- /proc/sys/net/ipv4/tcp_sack: bool // Selective Acknowledgment
- /proc/sys/net/ipv4/tcp_timestamps: bool // 是否允许记录 RTT(Round Trip Time)
- /proc/sys/net/ipv4/tcp_syn_retries: u8
- /proc/sys/net/ipv4/tcp_max_syn_backlog: u16 // 最大 SYN 连接数(server SYN_RECV 状态等客户端 ACK)
- /proc/sys/net/ipv4/tcp_max_orphans: u16 // 最大孤儿连接
- /proc/sys/net/ipv4/tcp_fin_timeout: u16 // 孤儿连接在内核中的生存时间
- /proc/sys/net/ipv4/tcp_retries1: u16 // 最大重传次数
- /proc/sys/net/ipv4/tcp_congestion_control: String // 当前操作系统用的拥塞算法
- /proc/sys/net/ipv4/tcp_rmem: (u32, u32, u32) // TCP 接收缓冲区大小限制
- /proc/sys/net/ipv4/tcp_wmem: (u32, u32, u32) // TCP 发送缓冲区大小限制
