# [高性能服务器读书笔记 3](2021/07/linux_high_performance_server_programming_3.md)

## 正向代理/反向代理/透明代理

- 正向代理: request google.com <-> shadowsocks_client(1080) <-> proxy_server <-> google.com
- 反向代理: 客户端无需设置，服务端 nginx 把请求转发给相应处理的服务去处理
- 透明代理: 只能设置在网关/路由器上

## 「实验_4」squid 代理服务器

tcpdump 记录方和 squid 代理服务器都在 192.168.1.75

§ 1. \[192.168.1.75]$ sudo systemctl start squid

§ 2. fuser 查看 squid 代理服务器端口 3128 的占用情况

```
[192.168.1.75]$ sudo fuser 3128/tcp
3128/tcp:            10176
```

§ 3. \[192.168.1.65]$ http_proxy=192.168.1.75:3128 wget www.baidu.com

wget 可以加上 `--header="Connection:close"` header 参数告诉服务器处理完 HTTP 请求后主动关闭 TCP 连接

!> 默认的 Connection header 是 keep-alive 也就是请求处理完不会关闭 TCP 连接

### 实验记录

![](proxy_http_request_flow_graph.png)

![](proxy_http_request.png)

#### 代理前后 HTTP 请求的 header 变化

代理前有 Proxy-Connection 代理后去掉了

代理后新增 header:
- Via: 1.1 ww(squid/4.16)
- X-Forwarded-For: 192.168.1.65

## cookie

HTTP 由于无状态，需要借助 Cookie (客户端往后的每一次请求都带上 Cookie) 实现状态上下文

让服务端区分具体是哪一个客户端，实现自动登陆等效果

## bind()

服务端需要通过 bind() 去命名 socket 才能让客户端知道该如何连接它

客户端则不需要命名 socket 通常匿名方式由操作系统分配 socket 地址

## close()

注意 close() 并不是立即关闭连接，而是把 fd 的引用计数 -1 (例如 fork 多进程的 TCP echo server 中要等 fd 的引用计数为 0 才真正关闭)

如果想立即关闭连接更建议用 shutdown()

## shutdown()

相比 close() 而言 shutdown(int sockfd, int how) 更像是专门为 socket 连接而设计的 API

### std::net::Shutdown

```rust
pub enum Shutdown {
    /// SHUT_RD
    Read,
    /// SHUT_WR
    Write,
    /// SHUT_RDWR
    Both,
}
```

## TCP send()/recv()

相比建立 TCP 连接后对 sockfd 直接 read()/write() , send/recv 多了更多读写控制

### TCP OOB 带外数据

由于 TCP 紧急数据的缓冲区大小只有 1 byte，所以带外数据可能会被截断

### sendto/recvfrom

UDP 的 sendto/recvfrom 不仅用于 UDP 和 socket_raw 还能用于 TCP (只需要将两个地址参数设为 NULL 因为 TCP 已知对方地址)

### sendmsg/recvmsg

更通用的 API TCP/UDP 都能用，参数是 sockfd + msghdr 结构体 + flags

## 带外标记

内核通知应用程序带外数据的方式: SIGURG 和 IO 复用产生的异常事件

### int sockatmark(int sockfd)

判断 sockfd 是否处于带外标记，返回 1 表示下一个读到的数据是带外数据

## 为啥 `sudo netstat` 看不到本地 TCP echo 数据

如果 TCP echo 的 server 和 client 都是 localhost

则会走 lo 网卡设备的流量，可能 netstat 默认观察 WiFi 网卡流量所以就看不到我们自己写的 TCP echo 程序流量

### sudo tcpdump -i lo

指定用 lo 设备才能观察到客户端和服务端都是 localhost TCP 流量

## setsockopt

必须在 server listen 前设置，accept 之后的 client_sockfd 会继承 server_sockfd 设置好的属性

### SOL_SOCKET

#### SO_REUSEADDR

强制使用处于 TIME_WAIT 状态连接占用的 socket 端口
