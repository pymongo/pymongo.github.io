# tokio

早期版本 tokio-0.2 基于 mio 抽象封装了 reactor, 现在叫 IO driver 和 parking

原因是为了支持 proactor/io_uring 这样的抽象，所以要在 reactor/executor 上进一步抽象出 driver+park

## 怎么处理 CPU 密集型/计算密集型耗时的任务

例如大量数据哈希运算，并不是 IO 操作导致耗时，有很多同步的 blocking 代码

tokio 文档中给出 tokio::task::spawn_blocking 介绍专用于大量耗时的同步代码
