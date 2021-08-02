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

#### SO_RCVBUF/SO_SNDBUF

TCP 接收/发送缓冲区大小，受到内核参数(/proc/sys/net/ipv4/) tcp_rmem 和 tcp_wmem 的限制

例如在我操作系统的默认内核参数中，不准把 TCP 缓冲区设置低于 4096 大小

#### SO_RCVLOWAT/SO_SNDLOWAT

用于 epoll/select 当 TCP 缓冲区数据大于其低水位标记时，就会触发 epoll_wait

#### SO_LINGER

设置 close 之后的行为:
1. SO_LINGER 不起作用
2. close 之后丢弃发送缓冲区的数据，同时给对方发 RST，让服务器知道连接异常终止
3. 看 socket 是阻塞还是非阻塞 IO 和发送缓冲区残留数据发送后等对方确认，close 的返回值会有不同结果

## 网络信息

### gethostbyname A 类查询

先去 /etc/hosts 去找，没有的话再请求路由器上的 DNS 服务器去查

### gethostbyaddr 反向 DNS 查询

反向 DNS 查询，根据 A 类 IP 地址查询域名、CNAME 等信息

### `_r` 结尾的系统调用无状态可重入

不可重入的系统调用函数一般都会用到 libc.so 的静态变量例如:

```
char* addr_1 = inet_ntoa(1);
char* addr_2 = inet_ntoa(2);
// 此时 addr_1 和 addr_2 都指向同一块 libc.so 的静态字符串内存，且都为 2
```

可重入(re-entrant)系统调用函数名都会带 `_r` 后缀

### 分配了堆内存的系统调用都会提供配套的 free_xxx

例如 freeaddrinfo

## some I/O function

### pipe

如果写管道 `fd[1]` 的引用计数为 0 则 read 会直接长度 0 表示 EOF

反之如果 `fd[0]` 的引用计数为 0 则 write 会引发 **SIGPIPE** 信号

### 双向管道 socketpair()

事实上创建的是一对 (server, client) 互相连接的 sockfd，只能在 AF_UNIX 本机使用，

> int socketpair(AF_UNIX, SOCK_STREAM or SOCK_DGRAM, 0, int `fd[2]`)

可能 socket pair 在内核中 IO 模型跟 pipe 类似所以 man 文档中 SEE ALSO 会有 pipe

### dup/dup2

注意 dup/dup2 复制的新 fd 并不会继承原有 fd 的属性，例如 close_on_exec 或 non_blocking 属性等

#### dup 实现 CGI

accept 之后 close(STDOUT_FILENO) 然后将 client_sockfd 复制成 fd == 1

此后服务端任何 printf 的输出都会被客户端获取到而非打印在终端上

### readv/writev iovec

相当于简化版的 recvmsg/sendmsg

```rust
pub fn writev(fd: ::c_int, iov: *const ::iovec, iovcnt: ::c_int) -> ::ssize_t;
pub fn readv(fd: ::c_int, iov: *const ::iovec, iovcnt: ::c_int) -> ::ssize_t;
pub struct iovec {
    pub iov_base: *mut ::c_void,
    pub iov_len: ::size_t,
}
```

对多块分散的内存数据进行读写

应用: 在 HTTP response 中 Header 和 body 两部分可能会分散在两块内存中

### sendfile

两个 fd 之间「零拷贝」传递数据，in_fd 像 mmap 那样要求不能是 pipe 或 socket

而 out_fd 则必须是 socket 显然这是专门为网络传输文件而设计的 API

这个 API 是直接把文件传送给客户端，没有用 read() 之类读一遍应用程序的 `Vec<u8>` 用户态缓存

### MAP_SHARED | MAP_ANONYMOUS

mmap 的 flags MAP_SHARED/MAP_PRIVATE 多加一个 MAP_ANONYMOUS 可以不绑定文件 fd

也就是类似 SQLite 那种 in-memory 数据库，也就是进程结束后数据就没了不持久化存储

### MAP_FIXED

start_addr 必须硬盘 4k 对齐的整数倍，也就是不会落到 4k page 的中间某个点

MAP_FIXED 可以让数据区段对硬盘 4k 对齐更友好

### MAP_HUGETLB

按 /proc/meminfo 的 Hugepagesize 属性来分配内存

### splice

用于两个 fd 之间「零拷贝」移动数据，两个 fd 必须至少有一个是 pipe 类型

所谓「零拷贝」也就是没有内核态和用户态之间的拷贝，不需要用户态定义 buffer 接收数据，并不是内核态内部

参数:
- fd_in
- off_in: offset of fd_in
- fd_out
- off_out: offset of fd_out
- len
- flags

注意事项:
- 如果 fd_in 是一个 pipe 则 off_in 必须设为 NULL 否则报错 ESPIPE
- off_in==NULL 表示从当前 cursor 偏移位置读取数据

flags 的可取值:
- SPLICE_F_NONBLOCK: 但实际效果会受到读写双方两个 fd 是否开启 NONBLOCK 的影响
- SPLICE_F_MORE: 给 kernel 提醒后续的 splice 调用会读取更多数据

#### splice zero copy echo server

创建一个管道，从 TCP 接收缓冲区接收到的数据经过管道流到 TCP 发送缓冲区原封不动发给客户端

用户态不需要创建 buffer 暂存客户端发来的数据，buffer 在内核态的 pipe 内部，减少了用户态和内核态之间的切换

> splice() moves data between two file descriptors without copying between kernel address space and user address space

### tee

跟 splice 类似，不过 tee 是 copy 拷贝数据而 splice 则是 move

### SIGIO

必须关联某一个 fd 才能使用，当被关联的 fd 可读写时将触发 SIGIO

通过 fcntl(file control ntl) 的 F_SETSIG 进行设置，然后传递给指定的宿主进程或进程组

使用 SIGIO 时还需要用 fcntl 将 fd 设置成 O_ASYNC

但 SIGIO 信号模型并非真正的异步 IO 模型

## syslog

> /dev/log: symbolic link to /run/systemd/journal/dev-log

syslog() -> /dev/log -> /run/systemd/journal/dev-log

or 

syslog() -> /dev/log -> syslogd/rsyslogd -> /var/log(by rsyslog config)

How kernel log to syslogd?

kernel_log printk() -> kernel ring buffer ->
1. copy to dmesg
2. /proc/kmsg -> syslogd

注意不要 cat /proc/kmsg 要用 dmsg 或 klogd 去查看 kmsg 日志

## UID/EUID/SUID

EUID: Effective(有效) UID
- EUID is changed by executable file(eg. sudo) that is configured SetUID authority
- EUID temporarily stores another account’s UID

SUID: Saved UID 
- When process’s authority is changed to lower. previous EUID is stored at SUID

EUID=root 的进程称为: privileged processes

进程的 UID 是启动程序的用户 ID 而 EUID 则是文件拥有者的 ID

例如可执行文件 chown root:root 之后 chmod +s (set-user-id flag) 之后运行 UID=1000, EUID=0

## 进程组(docker?)

## 进程组会话

## daemon()

daemon() 系统调用: fork 一个进程后台运行服务端应用，关闭 STDIN/STDOUT/STDERR

## 服务端框架

- IO 处理单元: select() 处理客户端连接，作为接入服务器，实现负载均衡
- 逻辑单元: 业务线程或者进程
- 网络存储单元(可选): 数据库，缓存，文件。但在 SSH server 上就不需要存储单元
- 请求队列(池)/消息队列: 各个单元之间的通信方式 

## 非阻塞 IO

由于不会像 BLOCKING IO 那样让线程 sleep 挂起，然后等内核通知唤醒

频繁轮询 非阻塞 IO 数据是否准备好又浪费性能

「所以非阻塞 IO 一定要搭配其它 IO 通知机制一起使用，例如 IO 多路复用或 SIGIO 信号 」

IO 多路复用例如 epoll 一般也是阻塞的，它能并发处理多个请求提高效率是因为具有同时监听多个 IO 事件的能力

从理论上来说 阻塞 IO，IO 多路复用，信号驱动 IO 都是同步 IO 模型

因为这三种 IO 模型的读写操作都在 IO 时间发生之后由应用程序来完成的

## AIO

用户告诉内核用户态的读写缓冲区位置，以及内核 IO 操作完成后通知应用程序的方式

AIO 的读写操作总是立即返回，不管 IO fd 是否设置成阻塞

「因为真正的读写操作已经被内核接管」

同步 IO 通知的是 IO 就绪事件，然后再从内核空间中读写到用户空间

而 AIO 向用户空间通知的更像是「IO 完成事件」

但是 AIO 数据从内核空间写到用户空间依然有大量拷贝开销

所以也就有了 io_uring 通过 mmap 让内核空间和用户空间共享一段内存从而零拷贝
