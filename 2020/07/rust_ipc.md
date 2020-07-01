# [Rust进程间通信](/2020/07/rust_ipc.md)

[进程间通信](https://songlee24.github.io/2015/04/21/linux-IPC/) (IPC，InterProcess Communication)的方式通常有

管道、消息队列、信号量、共享存储(数据库?)、Socket、Stream等

其中Socket和Stream支持跨主机之间的进程通信

还有一些更高层的抽象，例如WebSocket、HTTP、redis_pubsub、RPC也能实现类似跨进程通信的效果

我调研了一下，发现[socket](http://kmdouglass.github.io/posts/a-simple-unix-socket-listener-in-rust/)
和gRPC可能是最好的解决方案

也有推友提示说: 还是需要主动拉取状态对象来实现，靠推送不靠谱

## 全双工信道

想起了大学时学的几种电路通信协议，好像《通信原理》课程中也有涉及

UART、SPI是全双工，I2C是半双工信道，同时只能收或发

## IPC channel

Mozilla用Rust语言开发的Servo浏览器中，有一个代码仓库叫ipc-channel，用于Rust进程间通信，可以关注下
