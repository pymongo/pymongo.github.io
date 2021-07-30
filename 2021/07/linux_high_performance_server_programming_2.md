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
- acknowledgement_number: u32 // ack，解决不丢包问题
- data_offset: u4,
- reserved: u6,
- /// flags.URG, Urgent Pointer
- /// flags.ACK,「重要」表示收到的 ack_num 有效
- /// flags.PSH(push), 告诉接收端应该立即从 TCP 缓冲区读取数据，为后续数据腾出空间
- /// flags.RST, 要求重新建立连接
- /// flags.SYN,「重要」要求建立连接，含 SYN 的叫同步报文
- /// flags.FIN,「重要」通知对方本端要关闭连接
- flags: u6, // URG(Urgent Pointer), , , , SYN()，
- window: u16, // TCP 流量控制，告诉对方本端 TCP 缓冲区剩余容量，让对方根据剩余容量控制发送速度
- checksum: u16, // CRC 算法校验 TCP 头部+数据部分
- urgent_pointer: u16, // 或者叫紧急偏移
- options: variant // 

#### 三次握手建连接和 ack

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

#### 为什么建立连接要三次握手

双方都需要互相发一个 SYN，以及初始化各自的 seq_num

client connect() 后收到 server 返回的 SYN+ACK，client 端进入了 TCP 状态机的 ESTABLISHED 状态

然后 client 返回一个 ACK，server 收到后才能进入 ESTABLISHED 状态，这也是必须要握手 2 和 3 才能让 server 进入 ESTABLISHED 状态

#### 四次挥手断连接

1. A->B: FIN | ACK
2. B->A: ACK
3. B->A: FIN | ACK
4. A->B: ACK

由于 TCP 全双工，看上去实际上像是双方各发一个 FIN 两次，因为两次 ACK 都是被动回复的

因为收到 FIN 请求的一端，需要确认缓冲区没有数据要发送才会发一个 FIN，2MSL
