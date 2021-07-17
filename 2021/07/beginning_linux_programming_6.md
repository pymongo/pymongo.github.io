# [BLP 读书笔记 6](/2021/07/beginning_linux_programming_6.md)

「重要」ch13 POSIX thread

## how to define thread

Multiple strands of execution in a single program are called threads

thread is a sequence of control within a process

all processes at least one thread of execution

subprocess created by fork scheduled independently

### main_thread == process ?

TODO

### threads share data in process

global static var, fd, signal_handers, current_dir_state

### user-level thread and kernel thread

### 为什么不要 subprocess

线程开销比进程少，而且线程间切换比操作系统进程间切换要快

## `_r` 后缀的系统调用函数名

_r 表示 re-entrant (可重入)，也就是可以在不同线程间调用(不会共享一个动态库的static变量)

例如 localtime_r, gethostbyname_r

## **Synchronization with Semaphores**

mutex aka mutual exclusion

### binary semaphores

semaphore 跟 Mutex 都是保证多线程读写同一个变量变得原子性

同一时间只能有一个线程读写该变量

binary semaphores 约等于 mutex

### sem_init

> fn sem_init(sem: *mut sem_t, pshared: c_int, value: c_uint) -> c_int;

- sem: semaphore object
- pshared: 0 means semaphore is local to current process, otherwise semaphore can share between processes
- value: semaphore object initial value

### sem_post

> fn sem_post(sem: *mut sem_t);

function: atomically increase sem_t value by 1

### **sem_wait**

> fn sem_wait(sem: *mut sem_t);

function: atomically decrease sem_t value by 1

since **sem_t value is unsigned**, if sem_t.value == 0, sem_wait would wait until it's value become 1

> if value==0, the function would wait until other thread has increase the value so that it's non-zero

如果同时有两个线程在等 sem_wait 信号量大于 0

当第三个线程把信号量自增到 1 时，这两个 sem_wait 的线程只能有一个可以结束 wait 并将信号量减 1

### sem_trywait

non-block version sem_wait

### sem_destroy

## **atomic和内存屏障**

atomic 其实是x86架构硬件指令，所以所有编程语言都支持，atomic并不是C/C++的标准库

内存屏障概念跟atomic API有联系，通过程序员指定读写屏障 阻止 编译器为了优化打乱重排语句执行顺序 

- Ordering::Relaxed 没有限制
- Ordering::Release 用于写操作，写内存屏障
- Ordering::Acquire 用于读操作，读内存屏障
- Ordering::AcqRel  Release和Acquire的结合
- Ordering::SeqCst 在 AcqRel 的基础上，要求所有CPU核心和线程都要读写同步，最严格的原子序要求，性能也是最慢的

1. Load 的原子序操作: 只能 Relaxed/Acquire/SeqCst
2. Store的原子序操作: 只能 Relaxed/Release/SeqCst
3. compare_and_swap读+写: 建议用 AcqRel

### 写屏障

写屏障之前的所有写操作都要优先于写屏障后面的写操作

### 读屏障

读屏障之前的所有读操作都要优先于读屏障后面的读操作

### 全屏障

同时包含读屏障和写屏障

## pthread_mutex

### pthread_mutex_init

因为跨线程的缘故很难设置 errno，同 sem_init, pthread_mutex_init 出错时也不会设置 errno

## thread attribute

### **detached thread**

Rust glommio library use detach concept

detached is opposite to join, means main thread doesn't wait thread_2 exit

```
pthread_attr_t attr;
pthread_attr_init(&attr);
pthread_attr_setdetachstate(&attr); // if set, you can't pthread_join
pthread_attr_getdetachstate(&attr);
pthread_attr_destroy(&attr);
```

### **setschedpolicy** 设置线程调度策略

线程调度约等于进程调度?

- SHED_OTHER: default sched
- SHED_RP(need process run on sudo): round-robin scheduling, 循环轮换制
- SHED_FIFO(need process run on sudo):  

### pthread_attr_setscope

调度相关，超出本书范围，等基础够扎实再回来补课

### pthread cancel_state and cancel_type(immediately/defer)

cancel_state: PTHREAD_CANCEL_ENABLE or PTHREAD_CANCEL_DISABLE

cancel_state 决定线程是否接受 pthread_cancel 请求

**cancel_type**:
- PTHREAD_CANCEL_ASYNCHRONOUS: 线程收到 cancel 请求后立即结束
- PTHREAD_CANCEL_DEFERRED: until main thread join/cond_wait to cancel

默认是 PTHREAD_CANCEL_ENABLE + PTHREAD_CANCEL_DEFERRED

## **pthread_cond_wait**

从参数上来看需要搭配 mutex 一起使用，跟 mutex 区别在于:

acquire 锁的时候，线程可以 sleep 不用像 mutex 那样自旋锁似的不断轮询

然后等另一个线程释放锁后，用cond唤醒等待锁而进入休眠的线程即可

「重要」ch13 IPC: pipe

## popen/pclose (stdio.h)

> FILE *popen(const char *command, const char *open_mode);

pclose is to close FILE* open by popen

open_mode arg is either 'r' or 'w':
- 'r' means read STDOUT from invoke command
- 'w' means write to invoke command STDIN

所以说 pipe 不是双工通信，数据只能是单向流动，要么建两个 pipe 实现读写双工

if process execute waite statement before calling pclose, pclose would failed

如果是像 ps -ef 数据量很大的传递，都会在管道上分段传，block/chunk

### **wait** command

wait — await process completion

### why popen bad

popen invoke sh's pipe syntax and pass string command

every popen invoke a shell, so it has side effect

### libc::pipe

> int pipe(int file_descriptor[2]);

if success pipe() return 0, and fill reader_fd to arr[0], and fill writer_fd to arr[1]

pipe 最大作用就是线程间通信和父子进程之间通信，类似 tokio::sync::oneshot 单一通道

例如 fork() 返回 0 的子进程 上下文 context 中，去监听父进程往管道扔进来的数据

因为 writer 没发数据时，reader 会 suspend ，所以可以子进程可以一直等数据

注意用 exec 之后子进程会替换程序数据，所以 pipe 返回的 两个 fd 就取不到了

fork 之后的子进程，在 exec 时可以通过进程参数把 fd 传递到要替换成的可执行文件程序中

注意父子进程中的 reader/writer 两个 fd 都要关闭，所以这样其实不太合理

还是将进程的管道fd dup 复制一份成新的 fd再传递给其它子进程比较好

## **internal buffer in pipe**

if writer write data more than reader's buffer, writer suspend until reader consume last **internal buffer in pipe** data

if reader not receive data from writer, reader suspend until new data

### pipe内部buffer构造的 PIPE_BUF

linux/limits.h:

> #define PIPE_BUF        4096

注意 pipe 内部维护了一个缓冲区 PIPE_BUF 如果 writer 一次写入过多，

超过 PIPE_BUF 部分会让 writer 先别写，并让 writer suspend

等 reader 把 PIPE_BUF 读完后，再让 writer 写数据到 PIPE_BUF 中

有点像: 「单生产者-单消费者」:
1. 写线程会在 PIPE_BUF.is_full()  的被阻塞(操作系统干预)
2. 读线程会在 PIPE_BUF.is_empty() 时被阻塞(操作系统干预)
3. 读写线程都是BLOCKING_IO下，只要 PIPE_BUF 有数据，读写两个线程就同时工作

### 多个进程同时写一个 named_pipe

PIPE_BUF 的数据可能会发生重叠，必须保证不同线程进程间的写入是 atomic 的

server 端只有一个 FIFO 的 named_pipe 文件

client 进程请求 server 进程时携带上自身的 PID 数据

然后 server 从 /tmp/server_to_client_{PID} 管道中返回

#### ch13/server.c

为什么20个客户端请求不会对PIPE_BUF数据竞争?

!> 我的理解是 named_pipe 同一时间内只能有 读和写两个 fd，所以后面想获取写fd的客户端线程都在排队(queue up)

当read pipe失败后，server端需要重新打开named_pipe文件，反复循环，达到通过管道文件持续监听请求的效果

但是管道做 server-client 通信很大的问题是，只能 IPC 本机通信，不能网络通信，不符合业务需求

## mkfifo

命令行创建 `mkfifo $filename` 或者 `mknod $filename p`

除了命令，同样可以用 mknod 系统调用创建 named_pipe

### access syscall

检查文件是否存在用，Rust 标准库的 exist 用的是 stat 系统调用

当进程/线程 因 FIFO 被阻塞时，不会消耗任何系统资源

## O_NONBLOCK

FIFO reader can non-block even no writer

but if **writer open in non-block and no reader would failed**

<https://github.com/downloads/chenshuo/documents/LearningNetworkProgramming.pdf>

五大 IO 模型: 阻塞，非阻塞，同步，异步，信号驱动

NONBLOCK client.recv(1024) if no data to read, errno is EAGAIN(try again)

---

「重要」ch14 Unix System V IPC(Semaphores, shared_mem, message_queue)

## ch14 System V IPC(part 1)

ch13 讲了管道进行进程/线程间通信，但只能是单机通信IPC

由于这三个IPC API是同一个版本发布的，而且使用最广泛，所以归为一类

由于 socket 比整本书所有IPC通信方法加起来还要复杂得多，虽然也能 IPC, 但还是把 socket 划分到 网络编程(除了IPC还能跨机器同行)

## IPC semaphore

P(passeren) for wait, V(vrijgeven) for signal

P原语: pthread_sem_wait, decrease sem_var

V原语: pthread_sem_post, increase sem_var3

注意系统的 ipc_sem 是有限资源，进程用完后一定要析构

## IPC shared memory

注意 shared_memory 不会像 system_v_semaphore 那样保证原子性

- fn shmat: attach inited shared_memory to process address space
- fn shmdt: detaches the shared memory from current process

## IPC message queue

Linux 系统上有两种 MQ 的 API:

- System V: msgsnd/msgrec
- POSIX: mq_send/mq_receive

### 一个 sender 多个 receiver 会报错

System V 的 message queue 更像是 mpsc channel 多个生产者，一个消费者

一旦用成 spmc 则只有一个 receiver 会收到数据，其余的 receiver 会报错:

> Identifier removed (os error 43)

