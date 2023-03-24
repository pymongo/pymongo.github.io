# [reqwest 转为逐行流](/2023/02/reqwest_body_stream_to_tokio_buf_reader.md)

reqwest 作为 Rust 人气第一的 HTTP 库，我想逐行流式打印 K8s/docker log 接口返回的日志，但是只有 bytes_stream 方法返回一个 `Stream<Item=Bytes>`

虽然自己手动版 BufRead 实现如下，但能有现成的 Trait 用最好不要自己造轮子

```rust
let mut buf = Vec::<u8>::new();
while let Some(data_res) = futures_util::StreamExt::next(&mut rsp_stream).await {
    let data = match data_res {
        Ok(data) => data,
        Err(err) => {
            error!("{err}");
            buf.clear();
            break;
        }
    };
    buf.extend(data.to_vec());
    if !buf.ends_with(b"\n") {
        continue;
    }
}
```

按理说 tokio 生态的客户端，支持个 AsyncBufReadExt 不难吧，于是我按 `reqwest AsyncRead` 为关键词去查

作者说可以用 <https://github.com/seanmonstar/reqwest/issues/482>

> let stream = futures::TryStreamExt::into_async_read(rsp.bytes_stream());

```
expected `Result<_, Error>`, found `Result<Bytes, Error>`

note: `reqwest::Error` is defined in crate `reqwest`
    --> /home/w/.cargo/registry/src/rsproxy.cn-8f6827c7555bfaf8/reqwest-0.11.14/src/error.rs:16:1
     |
16   | pub struct Error {
     | ^^^^^^^^^^^^^^^^
note: `std::io::Error` is defined in crate `std`
```

看来要将 reqwest 流里面的 Error 转换下

```rust
// 仅作参考，reqwest 并不支持 unix socket
let rsp = reqwest::get("http://localhost/containers/CONTAINER_ID/logs").await.unwrap();
let stream = rsp.bytes_stream();
let stream = futures::StreamExt::map(stream, |x| match x {
    Ok(x) => Ok(x),
    Err(err) => Err(std::io::Error::new(
        std::io::ErrorKind::Other,
        err.to_string(),
    )),
});
let stream = futures::TryStreamExt::into_async_read(stream);
let mut stream = futures::AsyncBufReadExt::lines(stream);
let stream = async_stream::try_stream! {
    while let Some(line_res) = futures::stream::StreamExt::next(&mut stream).await {
        match line_res {
            Ok(line) => yield axum::response::sse::Event::default().data(line),
            Err(err) => {
                error!("{err}");
                break;
            },
        }
    }
};
Ok(Sse::new(stream).keep_alive(KeepAlive::new().interval(Duration::from_secs(45))))
```

`AsyncBufReadExt::lines` 本身就是一个 stream 了，还拿 try_stream! 包一层不是脱裤子放屁么

```rust
let stream = futures::AsyncBufReadExt::lines(stream).map(|x| match x {
    Ok(line) => Ok(Event::default().data(line)),
    Err(x) => Err(x),
});
```

---

## tokio compat

既然都用了 tokio 的运行时了，可能用 tokio 的 AsyncRead 比 futures 的 AsyncRead

(无论是 std,tokio 还是 futures, Read 表示读 bytes, BufRead 一般用于逐行读，lines/read_until 之类)

查资料真发现了一个转类型的工具 <https://github.com/tokio-rs/tokio/issues/2446>

**`tokio_util::compat`** 可以将 futures 和 tokio 的 AsyncRead 互相转

例如有个业务，已经结束的 pod 日志会存入硬盘，运行中的 pod 日志则调 K8s 接口查

我用 tokio 读完的日志文件可以转为 futures::stream

```rust
let file = tokio::io::BufReader::new(file);
let file = tokio_util::compat::TokioAsyncReadCompatExt::compat(file);
let stream = futures::AsyncBufReadExt::lines(file).map(|x| match x {
    Ok(line) => Ok(Event::default().data(line)),
    Err(x) => Err(x),
});
return Ok(Sse::new(stream).keep_alive(KeepAlive::new().interval(Duration::from_secs(45))));
```

---

## left_stream()

```rust
if container_is_running {
    return docker_logs_stream;
} else {
    return read_log_file_stream;
}
```

想做如上的业务逻辑，if 业务条件返回"类型不同"但数据一样的异步迭代器/流，结果报错

```
= note: expected struct `Sse<Map<Lines<Compat<BufReader<File>>>, [closure@run_log.rs:76:64]>>`
           found struct `Sse<Map<Lines<IntoAsyncRead<Map<impl Stream<Item = Result<Bytes, Error>>, ...
```

用 tokio_util::either::Either left_future 或者 FutureExt::boxed 都没能解决

**left_stream** 足以兜底，如果 if 有三个 branch 就 `Ether<Left, Ether<Left, Right>>` 以此类推

```rust
pub async fn handler(
    req: Json<Req>,
) -> Sse<impl Stream<Item = Result<Event, std::io::Error>>> {
    let stream = match handler_inner(req).await {
        Ok(x) => x.left_stream(),
        Err(err) => futures::stream::once(async move { Event::default().data(err.to_string()) })
            .map(Ok)
            .right_stream(),
    };
    Sse::new(stream).keep_alive(KeepAlive::new())
}
```

~~实在不行最终也能用将接口返回值改成 axum::response::Response 兜底(极不建议这样返回给前端的 content-type 会有多种)~~

## Stream map or then?

正常用 map 转换流的输出结果够了，如果流转换代码内有异步函数则用 **StreamExt::then**

```rust
let stream = futures::StreamExt::then(rsp.bytes_stream(), move |x| {
    let output_path = output_path.clone();
    async move {
        let data = match x {
            Ok(x) => x,
            Err(err) => return Err(std::io::Error::new(std::io::ErrorKind::Other, err)),
        };
        bypass_write_data_to_db(data.clone()).await?;
        Ok(Event::default().data("ok".to_string()))
    }
});
Sse::new(stream);
```

<https://gendignoux.com/blog/2021/04/08/rust-async-streams-futures-part2.html>

[How to pass variable to Stream::then](https://users.rust-lang.org/t/how-to-pass-variable-to-stream-then/60206)

## scan: stream mut state

如何完成这样的需求，累加/统计 reqwest body stream 总共返回了多少个字节

同步/异步迭代器 fold(有的语言叫 reduce) 可以在多个流之间共享可变状态，实现累加迭代器所有元素的效果

但是 fold 不是 lazy 惰性的会消耗掉迭代器，如果想**旁路**累加每次流元素的大小而不影响流元素返回，可以用 scan

<https://stackoverflow.com/questions/64044531/how-can-i-mutate-state-inside-async-block-with-streamextscan-method-in-rust>

最后如果编译器报错 StreamExt::scan 闭包返回值的引用或者生命周期问题，可以给闭包返回值包一层 future::ready 去解决

```rust
let file = std::sync::Arc::new(tokio::sync::Mutex::new(
    tokio::fs::OpenOptions::new()
        .write(true)
        .create(true)
        .truncate(true)
        .open(save_path)
        .await?,
));
let stream =
futures::StreamExt::scan(rsp.bytes_stream(), 0usize, |saved_bytes, incoming_res| {
    let incoming = match incoming_res {
        Ok(incoming) => incoming,
        Err(err) => {
            error!("{err}");
            return futures::future::ready(None);
        }
    };
    *saved_bytes += incoming.len();
    futures::future::ready(Some((incoming.to_vec(), *saved_bytes)))
})
.then({
    move |(incoming, saved_bytes)| {
        let file = file.clone();
        async move {
            let mut file = file.lock().await;
            file.write_all(&incoming).await?;
            Ok::<_, std::io::Error>(
                StreamRspItem {
                    saved_bytes,
                    total_bytes: content_length,
                    error: String::new(),
                }
                .to_sse_event(),
            )
        }
    }
});
```

一开始我是把 path move 到 then 回调里面每次打开文件 append 内容

小文件没问题，遇到大文件会导致下载到的内容大小一样但 md5sum 不一样看上去内容乱序

所以我不得不 move `Arc<Mutex<File>>` 进 StreamExt::then 闭包
