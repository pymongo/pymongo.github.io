# [BLP 读书笔记 7](/2021/07/beginning_linux_programming_7.md)

socket 并不是 Unix System V 提出的标准，而是 BSD 发明的，但由于过于流行现在所有操作系统几乎都支持

socket 像是 pipe 的扩展或升级版

server 会有个自己的 named_socket，server accept client_connection 之后会创建一个独立的 socket

每个客户端连接一个独立的 socket，客户端和服务端之间通过这个 socket 就能像操作 fd 那样双向通信

## local socket file server/client

server:
1. socket() -> server_socket_fd
2. bind(): create socket file and bind to server_socket_fd
3. listen(): listen server_socket_fd
4. accept() -> client_socket_fd

client:
1. socket() -> socket_fd
2. connect()

这个程序两个问题: 处理一个客户端连接时会阻塞线程，同时只能处理一个客户端轻轻

server 最多打开 1024 个 client_socket_fd 不能解决 C10k 问题

## socket(domain, type, protocol)

### domain arg

- AF_UNIX == AF_LOCK: local communication
- AF_INET == PF_INET: IPv4

其它选项不怎么用

### type arg

- SOCK_STREAM: usually with TCP/IP
- SOCK_DGRAM: usually with UDP/IP

UDP 数据包的不可靠体现在可能会: lost(丢包), duplicated, reordered

TCP aka Transmission Control Protocol, 
UDP aka User Datagram Protocol

### protocol arg

usually use 0, means default protocol

## inet_aton ip_string to ipv4_u32

```
MariaDB [test]> select inet_aton("192.168.1.1");
+--------------------------+
| inet_aton("192.168.1.1") |
+--------------------------+
|               3232235777 |
```

## INADDR_ANY == 0 == "0.0.0.0"

## **network byte ordering**

make sure server/client use same ordering

The htons() function converts the unsigned short integer hostshort from host byte order to network byte order

H(host_byte_order) TO N(network byte order) S(short)

example:
- server_address.sin_port = htons(8080);
- server_address.sin_addr.s_addr = htonl(INADDR_ANY);

## setsocketopt

socket level option:
- SO_KEEPALIVE: keep connections alive with periodic transmissions
- SO_LINGER: Complete transmission before close

## **select**

select — synchronous I/O multiplexing

和很多 API 一样 timeout 入参设置成 0 表示没有超时限制

### multiplexing - IO 复用

多路复用，例如 74HC151 8 选 1 数据选择器，选择一个已经就绪的数据

### select/poll/epoll

fd的存储上，select用的是限定1024长数组，poll用的链表，epoll用的是红黑树

poll 跟 select 没太大区别，poll 用链表实现因此没有 fd 上限(C10k问题)

epoll 可以开 几十万的 socket 连接， poll/select 的升级版，新内核推出的

### **ioctl**

因为 select socket 返回的都是流式数据，所以一般 select 都要配合 ioctl 使用

### **epoll**

- 水平触发机制(LT): 缓冲区只要有数据就通知，epoll默认工作方式，select/poll仅支持水平触发机制
- 边缘触发机制(ET): 缓冲区空或满时才通知，nginx就用这种，避免频繁读写

#### epoll **惊群** 问题

早期 kernel 版本的 epoll 明明每次只需要唤醒一个线程，却把所有线程都吵醒了，这就叫「惊群问题」，带来没必要的性能开销

### io_uring

Rust 主流异步框架例如 tokio 用的还是 epoll 阻塞或非阻塞的同步 IO

io_uring 让用户态和内核态共享两个环状队列，一个是提交请求，另一个是已完成的事件

存储上内核态和用户态共享内存(mmap)减少了系统调用次数，去掉了内核态数据往用户态拷贝的过程

aio 和 io_uring 基本上算是 异步非阻塞 io

## **IO复用两大经典模型模式**

### reactor 反应器模式「重点学习」，对应同步 IO

> synchronous I/O model is usually used to implement the Reactor mode

被动的事件分离以及分发模型: 被动等 select/epoll 的事件到了主线程再分发唤醒 worker 线程

main thread only monitoring whether an event(read/write) occur to socket fd,

if event occur notify the **worker thread** of the event to process fd

reactor 三种实现模式:
1. 单线程(相当于BLP select multi client的示例)
2. 主线程负责IOworker线程池负责业务
3. "主从"模式: 主线程只负责loop select，worker 线程负责 accept/read/write
- (reactor)main thread: (非业务)loop select/epoll_wait multi socket fd
- (executor)worker thread: (业务)accept connect, read, write

由于 aio 以前的效果不理想，所以 nginx/redis 都用的是 reactor

### proactor 主动器模式「可选学习」，对应异步 IO

> asynchronous I/O model is used to implement the Proactor mode

## tokio and mio

### 1. epoll_create, epoll_ctl, epoll_wait

### 2. mio

跨平台的 selector，将主流操作系统的 IO 多路复用的各种机制和数据结构通过 trait 和类型系统抽象成一个 mio 库

例如 `mio::{Poll, Event, Registry}` 和 `mio::net::TcpListener(包装了std::net::TcpListener)`

注意 non_blocking 只在 mio 的测试代码出现，所以 **mio 还是同步阻塞 IO**，所以 Idle 时 CPU 使用率几乎为 0

mio 的重要思想是把 epoll 抽象成 Poll, Event, Registry 这点必须理解

注意 mio 并没有实现 reactor 和 executor 具体实现则是在 tokio

mio 抽象后的 Poll 还是跟 BLP 的 select 例子差不多

例如 fd 是 server_socket 则 accept，否则去读 client 发来的数据

```
mio::Poll and syscall:
1. Poll::new() -> libc::epoll_create
2. Poll::Registry==mio::sys::Selector -> libc::epoll_ctl
3. Poll::poll() -> libc::epoll_wait
```

- token: 事件的 ID 约等于 socket 的 fd
- `mio::interest`: 事件的类型，只有读或者写

### 3. std Future and task

Future 是 trait，再通过 Generator 基础上实现了 Future 无栈协程状态机

### 4. futures-rs

在 std 的 Future 的基础上进一步提供更多的 AsyncRead, Task 之类的异步标准，为 tokio 和 async_std 所用

### 5. tokio TODO

## **UPD 不能 listen**

UDP 的 server 端没有 listen 和 accept 两个步骤

## netcat client

### test tcp echo server

> netcat localhost 8080 --tcp -vv

or

> telnet localhost 8080

### **telnetl send close**

`Ctrl + ]` and then type `quit`

### test udp echo server

> netcat localhost 8080 --udp -vv

## future

### `std::task` 约等于协程 ?

绿色线程/协程之间是一个用户态的非抢占式调度，需要协程主动让出时间片

当前协程干完活之后，用 `std::task::Waker` 抽象去唤醒其他协程干活

1. Future,异步计算的抽象
2. Task,Future之上的抽象协程，Task是可以调度的，也可以组合多个Future再 spawn 一个 Task协程 去执行
   但是Task还是需要基于异步运行时去运行
3. executor 异步运行时的异步执行器，用来 spawn task协程，以及用户态的协程调度

### 为什么要有 async/await 语法糖

为了编程体验更好，用同步的写法写异步代码

例如 promise 的 and_then 如果数据还没准备好，就切换到其它用户态的协程

### 为什么用户态的协程只能是「协作调度」cooperation

Linux 默认下线程都是 preemptive 抢占式调度线程按时间片为单位去切换运行，不需要 yield

---

## ch16 gtk

## gtk 库包含

- glib: gtypes(gint, ...), data-structure, event-loop, dynamic loading
- gobject: OOP lib for C
- Pango: text rendering and layout
- ATK: accessibility tools, eg. screen reader
- GdkPixbuf: manipulate image
- GDK: GIMP Drawing Tool, render on top of xlib
- xlib

## gtk 的 多态

大部分通过宏来实现，例如 GTK_CONTAINER(window) 可以将 GtkWidget down_cast 成其子类 GtkContainer

## **gtk-demo**

类似 `python -m turtledemo`

会打开一个源码+示例的列表，就像 python 的 turtledemo

## **pkgconf**

原理: 通过搜索 /usr/lib/pkgconfig 目录下的 *.pc 文件，例如:

```
[w@ww ~]$ pkgconf --path gtk4
/usr/lib/pkgconfig/gtk4.pc
```

我们只用关心 gtk4.pc 文件的 Cflags 和 Libs 设置，前者表示 gcc -I 参数引入的头文件文件夹，后者表示 gcc -L 要链接的动态库文件夹

```
[w@ww ~]$ cat /usr/lib/pkgconfig/gtk4.pc 
// ...
Version: 4.2.1
Requires: pango >=  1.47.0, pangocairo >=  1.47.0, gdk-pixbuf-2.0 >=  2.30.0, cairo >=  1.14.0, cairo-gobject >=  1.
// ...
Libs: -L${libdir} -lgtk-4
Libs.private: -lz
Cflags: -I${includedir}/gtk-4.0
```

## gtk_hbox_new(homogeneous: bool, spacing: i32)

homogeneous 表示均匀的，表示 box 容器内部的子组件的大小是不是等宽排布

spacing 则是表示组件间的间隙

注意这是已经过时的 API, gtk 3.0 要用 gtk_box_new

### gtk_box_pack_start

如果是 hbox, start 则是把组件加到 hbox 左侧

如果是 vbox, start 则是把组件加到 vbox 底下(bottom)

参数简介:

- box: vbox/hbox 指针
- child: 要加到 box 的子组件
- expand: 子组件填充满 box
- fill: 仅当 expand=true 时能用，表示是否取消 padding
- padding: 类似 CSS padding

### GTK+

GTK+ 提供跨平台的菜单栏等组件，功能类似于 gnome.h 的 gnome_program_init

---

## ch17 qt 

qt slot 约等于 gtk widget event callback

Q_OBJECT, signals, slots: 是 Qt 利用 C++ 元编程给 C++ 扩展语法关键词

### Meta Object Code

Qt 由于自定义了一些 C++ 扩展关键词，所以需要 moc 命令工具将 MyWindow.h 这类自定义的类重写成 xxx

这时候 Clion/CMake 就不好使了，要用 qtcreator 才方便构建项目(有 fakevim 模式文本编辑还凑合)

### Modal dialog

dialog 的 exec 跟 Gtk 一样，弹窗被强制聚焦，用户无法选择弹窗以外的窗口

---

## ch18 Standards for Linux

### gcc -pedantic

gcc -Wall 会包含 -pedantic，不知道会不会像 `clippy::pedantic` 那么强大
