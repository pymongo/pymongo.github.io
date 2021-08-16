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

## epoll

### epoll 边缘触发和水平触发

边缘触发必须将 fd 设置成 NONBLOCK

假如有 2 byte 数据，水平触发读了 1 byte 之后，还会通知用户继续读

如果是边缘触发，则只会通知一次，用户程序需要循环不断读取直到 EAGAIN 说明缓冲区为空

所以上述过程中 LT 会额外多通知一次，不如 ET 高效

redis 用的是 LT 而 nginx 用的是 ET

### epoll ONESHOT

解决什么样的问题:

reactor 通知 worker_1 读取 fd_1 的数据，但数据读到一半，reactor 又收到 fd_1 的新数据。
此时 reacotr 又唤醒 worker_2 去读写 fd_1 这样就造成 data race

ONESHOT 是怎么解决这个问题的:

ONESHOT 注册的事件同时只能触发一次，worker_1 操作完 fd_1 之后需要重置 fd_1 的 ONESHOT 事件。
经验是用于 accept 的 sockfd 不要设置 ONESHOT，客户端连接的 sockfd 可以设置成 ONESHOT

### epoll 和 select

select 每次都要轮询扫描所有注册的 fd，而 epoll 采用的是回调方式，内核检测到就绪的 fd 就触发回调并插入队列，
等适当的时机再把 events 队列 copy 到用户态中

但活动连接事件较多时，epoll 未必比 poll/select 效率高(尽管这两仅支持 LT)，因为此时回调函数触发过于频繁

因此 epoll 适合连接数很多，但是 fd 活跃事件比较少的应用场景

## getsockopt 获取 socket 错误

```c
int error = 0;
socklen_t length = sizeof( error );
getsockopt( sockfd, SOL_SOCKET, SO_ERROR, &error, &length );
```

## discard service

丢弃所有发向 discard 服务端口的数据包，可能用于测试吧

## 信号

### kill

pid 参数可选值:
- pid > 0: 发给 PID=pid 的进程
- pid = 0: 发给本进程组内的其它进程
- pid = -1: 除 PID=1 init 以外的所有进程
- pid = -n: 发给进程组 ID 为 n 的所有成员

一般用 bash 的管道语法糖可以创建进程组

### SIGTRAP

断点陷阱，用于 gdb/lldb

### 多线程环境下的信号处理

子线程通过 UDP socketpair 管道将信号发给主线程，只有主线程去处理信号，避免多个进程重复处理信号?

### **strace**

strace 能追踪可执行文件的系统调用和信号，输出内容非常多建议搭配 less 进行分页

### SIGHUP

xineted 通过这个信号重新加载配置文件

### send 函数的 MSG_NOSIGNAL flag

避免往一个接收端已关闭的 socket/pipe 写数据触发 SIGPIPE 导致进程直接退出

## 定时器

### 升序链表定时器

双向链表，还有一个字段是 回调函数 和 超时时间，每收到一个 SIGALRM 就 tick() 链表往前移动一个单位

用 应用层定时器进行 KEEPALIVE 会比 TCP 或 websocket 层方便些，也没 TCP 的 KEEPALIVE 复杂

例如客户端 socket 每次读写时都更新 expired 过期时间，再由 SIGALRM 定期清理过期连接

### 时间轮 定时器

解决定时器链表插入/添加效率低下的问题，时间轮是一个环状数组，每次 tick 都在环状数组中移动一位   

### 时间堆 定时器

动态的 interval = min(timers)

第一次 tick 最小定时器的时间，第二次 tick 第二小定时器的剩余时间 ...

数据结构上使用 min-heap 存储多个定时器

## libevent.so

使用 libevent.so 的知名应用: memcached, chrome

event 库中包含 双向链表/最小堆timer/DNS/HTTP/RPC 等功能

## 多进程

### fork()

fork 的子进程信号位图被清除，所以原信号处理函数将不起作用

子进程的数据复用采用的是 **Copy On Write**

当子进程想修改数据时，先发一个「缺页中断」然后操作系统给子进程分配相关数据的内存(从父进程复制数据过来)

父进程的 fd, working_directory 引用计数 +1

### 僵尸进程

1. 子进程先结束，一直等到父进程 wait() 读取子进程结束状态
2. 父进程先结束或异常中止，此时子进程的 PPID 设置为 1

解决方案: 子进程结束时会给父进程发 SIGCHLD，然后父进程在 SIGCHLD 回调中 waitpid(-1, ...) 彻底结束子进程释放资源

### POSIX shm

shm_open() + mmap()

首先要用 shm_open 打开一个 POSIX 共享内存的 fd 但文件名固定只能是 `/xxx` 这种格式，打开 fd 后再通过 mmap 经过文件共享内存

shm_open 打开的文件要 shm_unlink() 进行回收

使用 POSIX shm_open/shm_unlink API 编译时要链接上动态库 rt

共享内存的应用: 多进程并发服务器中，共享内存共享所有子进程的 socket read_buffer，每个进程读写偏移是 client_user_id 这样就不会互相干扰

这样能避免 fork 把一堆 buffer 也 fork 了造成资源浪费

### 两个进程间传递 fd

sendmsg() 系统调用一些参数和设置下和 cmsghdr 联合体，可以在两个进程间传递 fd

前提是只能在同一机器的 Unix Domain Socket

或者如果有权限(例如两个进程都是同一个用户)，直接告诉另一个进程通过 /proc 打开当前进程的 fd 也行

## 内核线程和用户线程

用户线程运行在用户空间，由 glibc 的 pthread 线程库进行调度

!> 当一个进程的内核线程获得 CPU 使用权时，它会加载并运行一个用户线程

### 线程的三种实现方式

按照 N 个内核线程和 M 个用户线程的比例，线程的实现方式可以分为三种:
1. 完全在用户空间实现
2. 完全由内核调度
3. 双层调度(two level schedular)

### pthread_create 创建的是什么线程

在现在 NPTL 实现中 pthread_create 创建一个用户线程的同时也会通过 clone() 创建一个内核线程

所以创建的线程和内核中调度实体的关系是 1:1 也有术语把 pthread_create 这样创建一对用户/内核线程的叫 naive thread

### io_uring 为什么 thread-per-core?

1. sched_setaffinity() 将 pthread_create 创建的线程固定在某个核去调度
2. io_uring 的机制是会启动一个内核线程

glommio 要确保二者的线程都在同一个 CPU 核调度避免上下文切换和锁

### 线程实现 - 完全在用户空间

无需内核支持，内核甚至不知道线程的存在，线程库负责管理执行线程例如时间片优先级等等，此时的用户线程就有点像协程

线程库通过 **setjmp**/**pthread_yield** 来切换线程的执行 (*Rust In Action* 书中亦有提到 longjmp 的实验)

但内核依然把整个进程当作最小单位来调度，所有线程共享该进程的时间片，对外表现出"相同的优先级"

M 个用户线程对应 N=1 个内核线程

!> 此时内核线程就等于进程本身

§ 完全在用户空间实现线程的优缺点:
- (+) 创建和调度无需内核干预
- (-) 多个用户线程无法运行在不同的 CPU 上，也就只能是 glommio/tokio-uring 那样 thread-per-core

### 线程实现 - 完全由内核调度

1 个用户线程被映射成 1 个内核线程

### 线程实现 - two level schedular

内核调度 M 个内核线程，线程库调度 N 个用户线程(`M<N`)

### 获取系统当前线程库版本

```
[w@ww temp]$ getconf GNU_LIBPTHREAD_VERSION
NPTL 2.33
```

### 早期 LinuxThreads 实现的缺点

clone() 创建的轻量级进程模拟内核线程会有以下问题:
- 每个线程都有不同 PID 不符合 POSIX 规范
- 信号处理本应基于进程，现在每个 naive 线程都能独立处理信号(因为是 clone 出来的进程)
- UID, GID 对同一个进程的不同线程来说可能不一样
- 程序生成的核心转存文件不会包含所有线程信息，只包含产生该文件的线程信息
- 最大进程数等于最大线程数
- 管理线程的引入带来额外的性能开销

### NTPL 如何解决上述问题
- 内核线程不再是一个进程
- 摒弃了管理线程、终止线程、回收线程(也就类似 join() 和 wait())
- 线程的同步由内核完成，不同进程的线程也能共享互斥锁

### join 的 deadlock 问题

EDEADLK: 两个线程互相 join 或者线程对自身进行 join

### thread_attr - guard size

在线程头尾额外分配 guard_size 的空间以保护堆栈不被错误的覆盖

如果线程属性包含 pthread_attr_setstackaddr 那么 guard_size 设置将被忽略

### thread_attr - scope

- PTHREAD_SCOPE_SYSTEM(Linux 仅支持): 线程和操作系统所有线程共同竞争 CPU 使用权
- PTHREAD_SCOPE_PROCESS: 线程仅跟同一进程下其它线程竞争 CPU 使用权

### pthread_mutexattr_t

对于不同类型的锁，lock/try_lock 会有不同的行为

- pshared: 是否允许跨进程共享互斥锁
- type_NORMAL_默认
- type_ERRORCHECK_检错锁: 重复加锁会 EDEADLK 而不会像默认锁那样死锁
- type_RECURSIVE_嵌套锁: 允许重复加锁，但也要执行相应次数

### **pthread_atfork**

不管进程有几个线程 fork 之后还是只有一个线程，且复制互斥锁之类的状态

pthread_atfork() 提供三个回调函数入参:
- prepare 函数指针在 fork 之前执行的回调
- parent 创建子进程后 fork() 返回值之前在 父进程执行的回调
- child 创建子进程 fork() 返回值之前在 子进程执行的回调

可以在三个回调中清理锁资源，确保子进程创建后「锁的状态是确定的」

### sigprocmask

由于进程中所有线程都共享该进程的信号，所以线程库通过信号掩码决定发给哪一个线程(前提是子线程所有信号掩码互相独立互不干扰没重复)

### pthread_kill

将指定信号发给一个线程。see also: sig_wait()

## sysctl

## fd 打开数量的限制

- 用户级限制: 进程能打开的最大 fd 数
- 系统级限制: 所有进程能打开的最大 fd 总数

ulimit -n 可以查看进程的 fd 限制

## 修改内核参数

临时修改系统最大 fd 总数:

> sysctl -w fs.file-max=max-file-number

永久修改系统最大 fd 总数:

> sudo cat fs.file-max=max-file-number >> /etc/sysctl.conf

然后 `sysctl -p` 重载 sysctl 配置文件

### sysctl -a 查看全部内核参数

## gdb

### attach PID

多进程多线程环境下，gdb 可以通过 attach 命令附加上子进程的 PID

### follow-fork-mode

多进程下，gdb 能开启 follow-fork-mode 模式

### info threads

### set scheduler-locking on

多线程环境下，只有当前调试中的线程才能运行

## IO 复用压力测试

client 用 IO 复用 压测服务器效率最高，避免线程切换的开销

## lsof -p

### FD

我的表述不算准确，具体看 man7.org lsof(8) 的 OUTPUT 部分

- rtd(root dir)
- txt(executable file)
- mem: memory-mapped file, 直接映射到内存中的文件(基本都是动态库)
- mmap: memory-mapped device

### DEVICE

#### lsblk

```
[w@ww ~]$ lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
nvme0n1     259:0    0 465.8G  0 disk 
├─nvme0n1p1 259:1    0   300M  0 part /boot/efi
└─nvme0n1p2 259:2    0 465.5G  0 part /
```

lsblk 只能列出 block devices

#### /proc/device

完整的 DEVICE_ID 要读取 /proc/device

文件所属设备，数据格式是 `主设备号,次设备号`，例如 259,2 表示 nvme 的分区 2 也就是 nvme0n1p2

1 表示 mem, 136 是 pts 伪终端设备

- A pts is the slave part of a pty
- A pty (pseudo terminal device) is a terminal device which is emulated by an other program eg. kconsole

### SIZE/OFF(offset)

如果是设备(例如 mmap memory-mapped device)则文件大小没有意义，将显示一个偏移值。否则显示文件大小

```
[w@ww ~]$ sudo lsof -p 2641900
lsof: WARNING: can't stat() fuse.gvfsd-fuse file system /run/user/1000/gvfs
      Output information may be incomplete.
lsof: WARNING: can't stat() fuse.portal file system /run/user/1000/doc
      Output information may be incomplete.
COMMAND     PID USER   FD   TYPE  DEVICE SIZE/OFF     NODE NAME
ssh     2641900    w  cwd    DIR   259,2     4096 12717985 /home/w/repos/my_repos/linux_commands_rewritten_in_rust
ssh     2641900    w  rtd    DIR   259,2     4096        2 /
ssh     2641900    w  txt    REG   259,2   887304 27667992 /usr/bin/ssh
ssh     2641900    w  mem    REG   259,2  3041456 27666951 /usr/lib/locale/locale-archive
ssh     2641900    w  mem    REG   259,2    51376 27665753 /usr/lib/libnss_files-2.33.so
ssh     2641900    w  mem    REG   259,2    92496 27665764 /usr/lib/libresolv-2.33.so
ssh     2641900    w  mem    REG   259,2    22200 27662455 /usr/lib/libkeyutils.so.1.10
ssh     2641900    w  mem    REG   259,2    55352 27662460 /usr/lib/libkrb5support.so.0.1
ssh     2641900    w  mem    REG   259,2    18184 27662345 /usr/lib/libcom_err.so.2.1
ssh     2641900    w  mem    REG   259,2   194544 27662450 /usr/lib/libk5crypto.so.3.1
ssh     2641900    w  mem    REG   259,2   940440 27662459 /usr/lib/libkrb5.so.3.3
ssh     2641900    w  mem    REG   259,2   589504 27662576 /usr/lib/libssl.so.1.1
ssh     2641900    w  mem    REG   259,2   154040 27665760 /usr/lib/libpthread-2.33.so
ssh     2641900    w  mem    REG   259,2  2150424 27665719 /usr/lib/libc-2.33.so
ssh     2641900    w  mem    REG   259,2   344176 27662427 /usr/lib/libgssapi_krb5.so.2.2
ssh     2641900    w  mem    REG   259,2   398560 27670873 /usr/lib/libldns.so.3.0.0
ssh     2641900    w  mem    REG   259,2   100096 27662645 /usr/lib/libz.so.1.2.11
ssh     2641900    w  mem    REG   259,2    22704 27665726 /usr/lib/libdl-2.33.so
ssh     2641900    w  mem    REG   259,2  2986824 27662350 /usr/lib/libcrypto.so.1.1
ssh     2641900    w  mem    REG   259,2   221480 27665708 /usr/lib/ld-2.33.so
ssh     2641900    w    0u   CHR   136,8      0t0       11 /dev/pts/8
ssh     2641900    w    1u   CHR     1,3      0t0        4 /dev/null
ssh     2641900    w    2u   CHR   136,8      0t0       11 /dev/pts/8
ssh     2641900    w    3u  IPv4 3793368      0t0      TCP ww:45380->xxx.compute.amazonaws.com:ssh (ESTABLISHED)
ssh     2641900    w    4u   CHR   136,8      0t0       11 /dev/pts/8
ssh     2641900    w    5u   CHR   136,8      0t0       11 /dev/pts/8
ssh     2641900    w    6u   CHR   136,8      0t0       11 /dev/pts/8
```

## nc/netcat

!> archlinux 要装 openbsd-netcat 别装 GNU 的 nc, centos/ubuntu 都用 BSD 的 nc

- -l, listener, server

§ sftrace

通过 sftrace 可以追踪 Linux 命令执行过程中调用了哪些系统调用及其错误码，为自己实现 Linux 命令作准备

## memory

### buff cache

从硬盘中读取的数据可能保持在 buff cache 中以便下一次快速访问

### page cache

准备写入到硬盘的数据将先放到 page cache 部分再由「硬盘中断程序」写入硬盘

## mpstat

每隔 1 秒采样一次 CPU 核心 1 的使用率

> mpstat -P 1 1 5
