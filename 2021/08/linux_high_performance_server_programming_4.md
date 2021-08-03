# [高性能服务器读书笔记 4](2021/08/linux_high_performance_server_programming_4.md)

## 事件处理模式: reactor/proactor

一定是异步 IO 才能用 proactor 吗？不一定用同步 IO 也能模拟出 proactor 事件处理模式

reactor 被动的事件分离以及分发模型，被动等 select/epoll_wait

reactor 只让主线程/IO处理单元监听 fd 的事件，如果有就通知 worker 线程

## proactor

将所有IO操作交给主线程和内核处理，worker线程只负责业务逻辑

aio(内核完成 socket 读写) 实现的 proactor 模式的 echo 服务器工作流程:

1. 主线程调用 aio_read 向内核注册 socket 的读取完成事件，并告诉内核要写到的用户态缓存变量的地址，以及通知方式
2. 内核向程序发生信号，通知 socket 数据已经读完了
3. 程序通过信号处理函数选择一个worker线程来处理客户请求，处理完请求后调用 aio_write
4. 内核通知 client_sockfd 写入完成，程序通知worker线程完成善后工作例如关闭 socket

用同步 IO 模拟 proactor 就是在 reactor 线程循环读写完所有 socket 数据后，再通过队列发给 worker 线程

## 并发模式

IO处理单元和多个逻辑单元之间协调完成任务的方法

### 半同步/半异步模式

### 领导者/追随者模式

领导线程监听到 socket IO 事件后，从睡眠的追随者线程中选一个成为新的领导继续监听 socket

然后旧领导自己变成追随者去处理 IO 事件

## epoll 边缘触发和水平触发

边缘触发必须将 fd 设置成 NONBLOCK

假如有 2 byte 数据，水平触发读了 1 byte 之后，还会通知用户继续读

如果是边缘触发，则只会通知一次，用户程序需要循环不断读取直到 EAGAIN 说明缓冲区为空

所以上述过程中 LT 会额外多通知一次，不如 ET 高效

redis 用的是 LT 而 nginx 用的是 ET

## epoll ONESHOT

解决什么样的问题:

reactor 通知 worker_1 读取 fd_1 的数据，但数据读到一半，reactor 又收到 fd_1 的新数据。
此时 reacotr 又唤醒 worker_2 去读写 fd_1 这样就造成 data race

ONESHOT 是怎么解决这个问题的:

ONESHOT 注册的事件同时只能触发一次，worker_1 操作完 fd_1 之后需要重置 fd_1 的 ONESHOT 事件。
经验是用于 accept 的 sockfd 不要设置 ONESHOT，客户端连接的 sockfd 可以设置成 ONESHOT

## epoll 和 select

select 每次都要轮询扫描所有注册的 fd，而 epoll 采用的是回调方式，内核检测到就绪的 fd 就触发回调并插入队列，
等适当的时机再把 events 队列 copy 到用户态中

但活动连接事件较多时，epoll 未必比 poll/select 效率高(尽管这两仅支持 LT)，因为此时回调函数触发过于频繁

因此 epoll 适合连接数很多，但是 fd 活跃事件比较少的应用场景

## getsockopt 获取 socket 错误

```cpp
int error = 0;
socklen_t length = sizeof( error );
getsockopt( sockfd, SOL_SOCKET, SO_ERROR, &error, &length );
```

## discard service

丢弃所有发向 discard 服务端口的数据包，可能用于测试吧

## kill

pid 参数可选值:
- pid > 0: 发给 PID=pid 的进程
- pid = 0: 发给本进程组内的其它进程
- pid = -1: 除 PID=1 init 以外的所有进程
- pid = -n: 发给进程组 ID 为 n 的所有成员

一般用 bash 的管道语法糖可以创建进程组

## SIGTRAP

断点陷阱，用于 gdb/lldb

## 多线程环境下的信号处理

子线程通过 UDP socketpair 管道将信号发给主线程，只有主线程去处理信号，避免多个进程重复处理信号?

## **strace**

strace 能追踪可执行文件的系统调用和信号，输出内容非常多建议搭配 less 进行分页

## SIGHUP

xineted 通过这个信号重新加载配置文件

## send 函数的 MSG_NOSIGNAL flag

避免往一个接收端已关闭的 socket/pipe 写数据触发 SIGPIPE 导致进程直接退出

## 升序链表定时器

双向链表，还有一个字段是 回调函数 和 超时时间，每收到一个 SIGALRM 就 tick() 链表往前移动一个单位

用 应用层定时器进行 KEEPALIVE 会比 TCP 或 websocket 层方便些，也没 TCP 的 KEEPALIVE 复杂

例如客户端 socket 每次读写时都更新 expired 过期时间，再由 SIGALRM 定期清理过期连接

## 时间轮 定时器

解决定时器链表插入/添加效率低下的问题，时间轮是一个环状数组，每次 tick 都在环状数组中移动一位   

## 时间堆 定时器

动态的 interval = min(timers)

第一次 tick 最小定时器的时间，第二次 tick 第二小定时器的剩余时间 ...

数据结构上使用 min-heap 存储多个定时器
