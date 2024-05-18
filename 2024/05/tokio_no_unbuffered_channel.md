# [tokio无零容量channel](/2024/05/tokio_no_unbuffered_channel.md)

今日tokio/bincode源码学习

tokio 没有 bounded unbuffered channel (tokio channel 会 assert len>0)
没有类似标准库 sync_channel(0) 或 ch := make(chan int)

oneshot类似于容量为零channel 但是一次性

为什么tokio没有零容量的channel?类似标准库的sync_channel(0)或者golang make(chan int)

> 涉及 async 那么发送和接收必须假定为可以非同时执行，所以就要有一个地方存放中间数据。
