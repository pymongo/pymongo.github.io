# [ipc json "粘包"](/2022/04/stream_do_not_read_to_end.md)

最近有个进程间一对一通信的需求，由于子进程可能会被 criu ptrace 换掉父进程的 pid，
而且子进程为了节省资源是通过 fork+exec 创建的所以无法使用 pipe/socketpair 等，
父子进程 pipe 貌似也是可以的，还没时间试成功，但是我父进程要启动多个子进程导致父进程的 stdout 不够用

## mkfifo ipc

一对一单向通信的 ipc 选择，管道最佳，毕竟 socket 还是有 server-client 一对多的设计会比 fifo 有更多开销，
fifo 命名管道不愧是 ipc 性能前几的选择，换上之后速度比 zmq 快了不少，比 pipe 更快的 ipc 可能就 mmap 和 shard memory

但我上 fifo 之后傻眼了怎么接收端 read_to_end 卡死？

原来是需要收到 EOF 「也就是发送端 close 才会发 EOF」才能读完

<https://www.reddit.com/r/rust/comments/hk4x1i/how_to_properly_stop_reading_from_a_fifo_named/>

## 每次收发都开关一次文件

发送端接收端每次收发都 open/close 一次总算能收到消息了，但是接收端收到的消息数量不确定，
并不是【逐条 json 收到】

bincode 报错 **SequenceMustHaveLength** 换 json 格式去看原来一次 read_to_end 可能收到 2 个 json 也可能是 3-4 个

多个 json 都粘在一起难怪 bincode 报错

## 消息长度或消息分隔符

效仿 LSP/HTTP 协议 json 之前有个 Content-Length header 告诉 json 长度，我参考了 rust-analyzer/lsp-server 代码改了下

但是还有问题是 read_line 读 header 可能返回空，且可能并不是阻塞 blocking 的读

第二个问题是【生产者消费者速度不一致】的时候可能读到的消息缺少几个 byte 导致反序列化报错

## 那换 socket ipc 试试？

用 socket read_to_end 还是遇到发送端不关闭就卡死的问题，看来 file stream 跟 socket stream 本质上一样的

## serde_json::from_reader

方案解决: <https://stackoverflow.com/questions/55797975/how-i-can-i-lazily-read-multiple-json-values-from-a-file-stream-in-rust>

让 serde_json/bincode 接管文件流的解析，这两都有对消息边界分隔符和消息长度的处理，这样就不会粘包，就能愉快的一条条收消息了

## tokio::select json reader?

tokio 好在 http/hyper/weboscket 等库生态极强且能 select 任何 future，但是引用无法共享只能 Arc::clone 变成 owned 去 move

crossbeam 的 select 也太弱了，只能 select crossbeam 自家的 channel 想 select 一个 fd 还得建一对 channel

我现在应用大多都是 hyper+tokio 只能说把 json/bincode reader(stream) 这样 blocking 的操作放到 tokio::spawn_blocking()

然后建一个 channel 将消息返回
