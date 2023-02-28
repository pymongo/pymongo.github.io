# [reqwest 转为逐行流](/2023/02/reqwest_body_stream_to_tokio_buf_reader.md)

reqwest 作为 Rust 人气第一的 HTTP 库，我想逐行流式打印 K8s/docker log 接口返回的日志，但是只有 bytes_stream 方法返回一个 `Stream<Item=Bytes>`

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

总觉得有点遗憾，既然都用了 tokio 的运行时了，可能用 tokio 的 AsyncRead 比 futures 的 AsyncRead

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

由于我函数既可能转发 HTTP body 返回日志流，也可能转发文件流来返回日志流，即便两个流返回值一样

但每个 async block 编译器内部上就是不同类型不同 generator

```
= note: expected struct `Sse<Map<Lines<Compat<BufReader<File>>>, [closure@run_log.rs:76:64]>>`
           found struct `Sse<Map<Lines<IntoAsyncRead<Map<impl Stream<Item = Result<Bytes, Error>>, ...
```

async Rust 经典问题了，这个问题下篇文章会详细讨论并解决

update:

用 tokio_util::either::Either 或者 FutureExt::boxed 都没能解决

axum `impl Stream` 不好处理多种流类型，只能通通 into_reponse 接口返回值改成 Response 就解决了
