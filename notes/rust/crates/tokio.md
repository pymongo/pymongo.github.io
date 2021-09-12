# tokio

早期版本 tokio-0.2 基于 mio 抽象封装了 reactor, 现在叫 IO driver 和 parking

原因是为了支持 proactor/io_uring 这样的抽象，所以要在 reactor/executor 上进一步抽象出 driver+park

## 怎么处理 CPU 密集型/计算密集型(computation-intensive)耗时的任务

例如大量数据哈希运算，并不是 IO 操作导致耗时，有很多同步的 blocking 代码

tokio 文档中给出 tokio::task::spawn_blocking 介绍专用于大量耗时的同步代码

或者使用 block_in_place() API: block current thread but would not block executor

block_in_place 会把当前线程的其他任务分摊到其他线程中，好让当前线程 block 例如等待 pipe 有数据

## tokio-rs/console

用于排查 tokio CPU 占用率高和 await 卡死的问题，能显示出 CPU 占用率高的协程是在第几行 spawn 的

但是 tokio-console 有个问题，监控的进程如果 CPU 负载很高时，监控 UI 就会卡死不动了，不可靠
