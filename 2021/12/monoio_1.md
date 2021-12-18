# [monoio 笔记 1](2021/12/monoio_1.md)

## 再复习下 epoll
IO 多路复用，类似数字电路数据选择器，多个 socket/fd 的 IO 设置成非阻塞注册 epoll_fd 的事件，
多个 fd 的 IO 变成一个 epoll_fd 的阻塞 IO (好像 epoll_wait 也能设置成让 epoll_fd 非阻塞)

## io_uring
主要由两个 ring 组成: Submission Queue 和 Completion Queue 组成，
SQ is write-only for user, CQ is kernel write-only，
如果 SQ 满了就要先 submit 一下，线程没事做就 submit_and_wait。

(submit_and_wait/submit 并不是 syscall 只是 liburing 对 enter 的封装)

## C/C++ libevent
例如一个 HTTP 请求可能分成 read_header::callback, write_header::callback

## links
- https://www.v2ex.com/t/821027
- https://github.com/ihciah/mini-rust-runtime/tree/master/src
- https://www.ihcblog.com/rust-runtime-design-1/
- https://github.com/bytedance/monoio
- [monoio 分享回放，基本跟作者四篇博客一样](https://rust-lang.feishu.cn/minutes/obcn4sbp86y9b2ng5b4smi4o)

reactor 有很多种不同模型，大体上都是一个 reactor 线程基本上负责 epoll_wait 的 main loop，
当 reactor 发现所有 task 都 block 在 io 的时候就会进入 park 状态调用 epoll_wait，
worker_thread 相当于 worker 线程

unpark 表示叫醒 worker_thread，
叫醒陷入 blocking syscall 的线程，
怎么主动叫醒别的线程，自己造一个假的 io_uring event 数据为空，然后业务代码再叫醒他

trait AsyncReadRent，Rent 的意思是租借

用户态把 buffer 借给 内核态，
等 内核态将 buffer 放到 complete queue

用户传入 &[u8] 的指针地址和长度，
在 monoio 存储 slab，返回 slab_index -> (Buf{ptr,len},lifecycle)，并绑定相应 Future/Task 的 cx，
slab_index 对标 mio 的 Token 也就是 epoll_event 的 u64 字段，
在 monoio 中抽象成 id 准备提交到 SQ 中， 
毕竟 lazy 执行的，更合理做法是kernel 用 buffer 时候才转移所有权

通过 CEQ(complete queue element) 返回的 id, reactor 再通知 

io_uring API submit_and_wait()

同步 syscall 的另一种解释，
同一时间内核和用户都在干读的事情，要么切换在内核去读要么在用户态等线程未必阻塞，
poll-like 语义意味着一种操作的尝试，用户态主动读，读失败也要继续，
异步 syscall 如果返回 would block 只是表示 kernel 正在干没干完别问了，没必要继续主动询问，
monoio-compact 兼容 tokio 的还是很多问题，强行兼容不保证 Future 每次 Poll 状态是一样的，
Poll 状态机有可能不一致，例如来了一个更高优先级的数据 IO

monoio-compact 必须保证用户发了 poll 之后数据包不能改，
例如第一次 poll Pending，用户可能将 IO 数据换成另外的数据包，
由于 第一次的数据包都已经发到 CQ 了，所以

另一种解决方法就是改造 kernel 定制 OS, 像蚂蚁那样代码不变，调用 Epoll 实际上系统底层用 io_uring，
字节和阿里内部有一些 Java/Go 支持 io_uring 的尝试，
go 的问题是没有内存屏障和 kernel 共同操作 ringbuffer 的时候，需要依赖一些 dirty 的手段（代码的关系依赖等），
现在好像只依赖了 undocumented behaviour？
go 的 atomic 其实是 SeqCst 的 Ordering，所以用 atomic 没啥问题，也不用担心 Go 编译器做指令重排（Go 编译器就没这个功能，没这么高级）

什么是运行时的更详细定义: 在有没有对callback做抽象和调度 rust 里的是 task 和 executor, libuv类似于 mio这样的 epoll等的封装。
我比较好奇mio对于windows iocp的支持，因为epoll和kqueue都是poll的，iocp和io uring类似吧
@郭勇这个其实类似于glommio对待uring的方式，它只把uring当做一个异步状态通知机制 然后做同步syscall，
uring里有个突破性技术 fastpoll 内核帮你处理fd的读写状态
poll-based io and completion-based io

epoll is a blocking operation (epoll_wait()) - you block the thread until some event happens and then you dispatch the event to different procedures/functions/branches in your code.
