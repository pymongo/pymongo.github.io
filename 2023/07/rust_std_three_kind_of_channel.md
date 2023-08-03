# [标准库 3 种 channel](/2023/07/rust_std_three_kind_of_channel.md)

```rust
enum SenderFlavor<T> {
    /// Bounded channel based on a preallocated array.
    // mpsc::sync_channel(100)
    Array(counter::Sender<array::Channel<T>>),
    /// Unbounded channel implemented as a linked list.
    // mpsc::channel()
    List(counter::Sender<list::Channel<T>>),
    /// Zero-capacity channel.
    // mpsc::sync_channel(0)
    Zero(counter::Sender<zero::Channel<T>>),
}
```

sync_channel 的行为跟 pipe 类似
- buffer 满的时候发送端会 block until buffer has space
- buffer 空的时候接收端会 block

buffer 大小为零的 channel 也叫 **rendezvous channel** 发送端 send 之后会持续 block 直到消费者接收完消息

```
gpt: does zero size pipe also call rendezvous channel?


No, a zero-size pipe is not the same as a rendezvous channel.

A zero-size pipe refers to a pipe with a zero-size buffer, as mentioned earlier. It allows for immediate data transfer between processes without any buffering or delay. However, it does not necessarily involve any synchronization or coordination between the sender and receiver processes.

On the other hand, a rendezvous channel is a communication mechanism that involves synchronization between two processes. It ensures that the sender and receiver processes meet at a specific point before the data transfer occurs. This synchronization can be achieved using various methods, such as explicit signaling or message passing, to coordinate the communication between the processes.

While both zero-size pipes and rendezvous channels involve inter-process communication, they serve different purposes and have different characteristics.
```

零大小的管道让我联想到 splice/sendfile 这样 zero-copy 的系统调用
