# [stream::unfold rsp](/2022/09/process_command_to_http_stream.md)

如果有个接口需要执行一个耗时很长的 command 导致 nginx 网关会 504

所以得想办法做成 HTTP stream body 

在 Golang 生态有很多劫持(hijacking) HTTP 当作 socket 去读写的使用

例如 docker engine API `/containers/{container_id}/attach`

在 Rust 生态无论是 axum 或者是其它 HTTP api server 框架，

这些框架都归一化到【提供 futures::Stream 框架帮你转成 HTTP stream】

## 实现思路

粗糙的实现是，先返回一个 keep-alive 的流，再 spawn 一个协程去 cmd.output().await? 再通过 channel 告知命令已经执行完流可以返回 None/EOF 了

更好的实现是 tokio::io::copy 把 stdout/stderr 合并拷贝到 stream body(没有这样的 API 要自己实现)

## futures::stream::unfold

Rust 还没有 loop+yield 没啥办法方便的将 loop-select 的代码 convert 成一个流

看看 futures::stream 文档的 function 部分都是流的构造函数

其中我熟悉的只有 `once` 用于造一个只有一条消息的流和 `iter` 构造无限长或固定长度的流

stream::iter 可以传入 `1..` 这样无限长的迭代器也可以传入有限长的

对于 loop+select 这样不确定长的流，我按 closure 关键词去搜就只有 unfold 可用

---

以下 unfold 代码显然会报错，因为 rx 会在多次流迭代中被 move 了多次

```rust
let (tx, mut rx) = tokio::sync::mpsc::channel(2);
tokio::spawn(async move {
    match cmd.output().await {
        Ok(output) => {
            tx.send(output);
        },
        Err(err) => {
            todo!()
        },
    }
});
let c = futures::stream::unfold((), |_| async {
    tokio::select! {
        // keep alive
        _ = tokio::time::sleep(std::time::Duration::from_secs(5)) => {
            Some(("keep_alive", ()))
        },
        r = rx.recv() => {
            None
        }
    }
});
```

看到满屏幕报错标红不要慌，看看各个地方的入参和迭代器

既然是 fold/reduce 那么有状态的东西需要继续传递

显然 rx 不是有状态的，但是为了下个迭代闭包能继续用还需要继续传递下去

```rust
axum::body::StreamBody::new(futures::stream::unfold(
    (rx, false),
    |(mut rx, is_eof)| async move {
        if is_eof {
            return None;
        }
        match tokio::time::timeout(std::time::Duration::from_secs(2), rx.recv()).await {
            Ok(output) => {
                if let Some(output) = output {
                    Some((Ok(output), (rx, true)))
                } else {
                    None
                }
            }
            Err(_timeout) => Some((Ok("keep_alive\n".to_string()), (rx, false))),
        }
    },
))
```

显然在很多异步库代码中我应该都看过这样的写法，只不过这次要我自己写了，又摸熟了几个编译器报错的可能，嗯学到了 stream::unfold 的正确写法了

## forward stdout

TODO 估计实现会麻烦很多

## future cancel

TODO 客户端取消请求后，future cancel 传播让 pip process 也 cancel 执行
