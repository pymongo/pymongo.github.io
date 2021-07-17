# [案例分析-重复释放资源获取消息队列状态失败](/2021/07/double_deconstruct_mq_cause_msgctl_failed.md)

假设 System V 消息队列的生产者和消费者共用以下代码

```rust
unsafe fn print_mq_status(msqid: i32) {
    // IPC_SET 命令是修改 MQ 的 msqid_ds 状态结构体
    let mut msqid_ds = std::mem::zeroed();
    let res = libc::msgctl(msqid, libc::IPC_STAT, &mut msqid_ds);
    if res != 0 {
        panic!("{}", std::io::Error::last_os_error());
    }
    libc::printf(
        "msqid_ds.msg_rtime(receive time) = %s\0".as_ptr().cast(),
        ctime(&msqid_ds.msg_rtime),
    );
}

unsafe fn run(is_receiver: bool) {
    let msg_size = std::mem::size_of::<Message>() - std::mem::size_of::<libc::c_long>();
    let msqid = libc::msgget(12, 0o666 | libc::IPC_CREAT);
    if is_receiver {
        let mut recv_data: Message = std::mem::zeroed();
        let res = libc::msgrcv(
            msqid,
            (&mut recv_data as *mut Message).cast::<libc::c_void>(),
            msg_size,
            2,
            0,
        );
        if res == -1 {
            panic!("{}", std::io::Error::last_os_error());
        }
        print_mq_status(msqid); // msgtcl panic
    } else {
        for chat_room_id in 1..=2 {
            let req_msg = Message {
                chat_room_id,
                request: Request::Join,
            };
            libc::msgsnd(
                msqid,
                (&req_msg as *const Message).cast::<libc::c_void>(),
                msg_size,
                0,
            );
            print_mq_status(msqid);
        }
    }
    libc::msgctl(msqid, libc::IPC_RMID, std::ptr::null_mut());
}
```

先启动 receiver 让其主线程阻塞在 msgrcv ，再启动 sender 给消息队列发送消息

为什么 sender 线程 print_mq_status 一切正常，但是 receiver 想打印 mq 的状态就会 EINVAL 呢

## 查阅资料

查阅 msgctl 的 man 文档:

> EINVAL The value of msqid is not a valid message queue identifier; or the value of cmd is not a valid command.

得到信息是 msqid 是 invalid 时会导致 EINVAL

阅读 BLP 的 MQ 例子解释:

> The sender program creates a message queue with msgget;
> 
> then it adds messages to the queue withmsgsnd.
> 
> The receiver obtains the message queue identifier with msgget 
> 
> and then receives messages until the special text endis received.
> 
> It then tidies up by deleting the message queue with msgctl.

重点是 **then tidies up by deleting**

## 分析原因

由于我发送方和接收方共用代码，发送方结束时把 MQ 系统资源给删掉了，所以接收方再去调用 msgctl 就会 EINVAL

所以这也算一种 double-free 的错误案例

## 解决办法

释放 MQ 系统资源时加上判断，只有 receiver 进程才能释放，避免 double-free

这样看来把 receiver 抽象成 server 只让 server 一个进程能删除 MQ 系统资源即可

那么 mpsc 应用场景，通过一个 MQ 怎样实现双工通信呢？还是等 IO 模型和 socket 基础学扎实了再去思考这个问题
