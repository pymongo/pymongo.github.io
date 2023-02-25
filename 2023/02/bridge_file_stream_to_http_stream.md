# [bridge tokio stream](/2023/02/bridge_async_file_stream_to_http_stream.md)

想做一个像 docker logs 那样的接口，把日志文件读取流实时转发到 HTTP 流中，让多个客户端可以实时获取日志流

生产者一个读日志的协程，消费者是多个客户端长链接，只能用 tokio::sync::broadcast 里面的 channel

```rust
let (tx, _rx) = tokio::sync::broadcast::channel::<String>(1000);
let tx_ = tx.clone();
tokio::spawn(async move {
    let tx = tx_;
    let mut child = tokio::process::Command::new("journalctl")
        .arg("--user")
        .arg("-f")
        .arg("--output")
        .arg("cat")
        .stdout(Stdio::piped())
        .stderr(Stdio::null())
        .spawn().unwrap();
    let stdout = child.stdout.take().unwrap();
    let mut stdout = tokio::io::BufReader::new(stdout).lines();
    use tokio::io::AsyncBufReadExt;
    while let Some(line) = stdout.next_line().await.unwrap() {
        tx.send(line).unwrap();
    }
});
```

最初我只会 futures::stream 里面的 stream::once 和 stream::iter

造一个不确定长度的 stream 用 reduce 糊了一个版本出来带有 keep_alive 功能, 因为 axum 所有 stream 都是 TryStream 所以 map 成 Infallible 的 Result

```rust
async fn stream_handler(
    State(tx): State<tokio::sync::broadcast::Sender<String>>,
) -> StreamBody<impl Stream<Item = Result<String, Infallible>>> {
    let rx = tx.subscribe();
    let stream = StreamBody::new(futures::stream::unfold(
        (rx, false),
        |(mut rx, is_eof)| async move {
            if is_eof {
                return None;
            }

            match tokio::time::timeout(std::time::Duration::from_secs(30), rx.recv()).await {
                // output.map(|output| (output, (rx, true)))
                Ok(output) => {
                    match output {
                        Ok(line) => Some((line, (rx, false))),
                        // EOF
                        Err(err) => Some((err.to_string(), (rx, true))),
                    }
                },
                Err(_timeout) => Some(("keep_alive\n".to_string(), (rx, false))),
            }
        },
    // future_utils::StreamExt or tokio_stream::StreamExt
    ).map(Ok));
    stream
}
```

但这样太啰嗦太难扩展了，看了下 tokio 文档 <https://docs.rs/tokio/latest/tokio/stream/> 

用 async_stream 可以将一个 channel 的 receiver 转换成 stream

```rust
async fn sse_handler(
    State(tx): State<tokio::sync::broadcast::Sender<String>>,
) -> Sse<impl Stream<Item = Result<Event, Infallible>>> {
    let mut rx = tx.subscribe();
    let stream = async_stream::try_stream! {
        loop {
            match rx.recv().await {
                Ok(x) => yield Event::default().data(x.to_string()),
                Err(err) => {
                    // dbg!(&err);
                    break;
                }
            }
        }
    };
    Sse::new(stream).keep_alive(
        axum::response::sse::KeepAlive::new()
            .interval(Duration::from_secs(30))
            .text("keep_alive"),
    )
}
```

async_stream::try_stream! 部分宏展开的代码是

```rust
let (mut __yield_tx, __yield_rx) = unsafe { $crate::__private::yielder::pair() };
$crate::__private::AsyncStream::new(__yield_rx, async move {
    loop {
        match rx.recv().await {
            Ok(x) => {
                __yield_tx
                    .send(::core::result::Result::Ok(
                        Event::default().data(x.to_string()),
                    ))
                    .await
            }
            Err(err) => {
                break;
            }
        }
    }
})
```

async_stream::__private::AsyncStream 为什么要实现 FusedStream

问了下 chatGPT 相关的 FusedFuture 是什么

> FusedFuture is primarily intended for use with futures that produce a finite number of values

stream! 宏估计跟 pin! 宏一样复杂，宏的实现一两句说不清，暂时就先不钻研了

知道例如有些自己造出来的 stream 要 pin 之后才能 poll/stream.next() 就行了
