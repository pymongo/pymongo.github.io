# [except Fn found closure](/2023/07/excepted_fn_found_closure.md)

在复用一段 stream 的代码的时候出现报错:

```
error[E0277]: expected a `Fn<(Result<bytes::Bytes, reqwest::Error>,)>` closure, found `[closure@crates/service/note_storage/src/handler/helper/k8s_helper.rs:53:48: 53:51]`
  --> crates/service/note_storage/src/handler/helper/k8s_helper.rs:39:3
   |
39 |   > {
   |  ___^
40 | |     let body = reqwest::ClientBuilder::new()
41 | |         // .default_headers(headers)
42 | |         .danger_accept_invalid_certs(true)
...  |
62 | |     Ok(lines_stream)
63 | | }
   | |_^ expected an `Fn<(Result<bytes::Bytes, reqwest::Error>,)>` closure, found `[closure@crates/service/note_storage/src/handler/helper/k8s_helper.rs:53:48: 53:51]`
   |
   = help: the trait `Fn<(Result<bytes::Bytes, reqwest::Error>,)>` is not implemented for closure `[closure@crates/service/note_storage/src/handler/helper/k8s_helper.rs:53:48: 53:51]`
   = note: `[closure@crates/service/note_storage/src/handler/helper/k8s_helper.rs:53:48: 53:51]` implements `FnMut`, but it must implement `Fn`, which is more general
```

```rust
pub async fn watch_pod_by_label_selector(
    label_selector: &str,
) -> Result<
    Lines<
        IntoAsyncRead<
            Map<
                impl Stream<Item = Result<Bytes, reqwest::Error>>,
                impl Fn(Result<Bytes, reqwest::Error>) -> Result<Bytes, std::io::Error>,
            >,
        >,
    >,
    reqwest::Error,
> {
    let body = reqwest::ClientBuilder::new()
        // .default_headers(headers)
        .danger_accept_invalid_certs(true)
        .connect_timeout(std::time::Duration::from_secs(10))
        .build()
        .expect("reqwest::ClientBuilder")
        .get(&*PODS_BASE_URL)
        .bearer_auth(&*TOKEN)
        .query(&[("watch", "true"), ("labelSelector", label_selector)])
        .send()
        .await?
        .error_for_status()?
        .bytes_stream();
    let stream = futures::StreamExt::map(body, |x| match x {
        Ok(x) => Ok(x),
        Err(err) => Err(std::io::Error::new(
            std::io::ErrorKind::Other,
            err.to_string(),
        )),
    });
    let stream = futures::TryStreamExt::into_async_read(stream);
    let lines_stream = futures::AsyncBufReadExt::lines(stream);
    Ok(lines_stream)
}
```

看了一圈建议都是 impl 改成 Box dyn 也就是最后一行加 boxed

> let lines_stream = futures::AsyncBufReadExt::lines(stream).boxed();

不仅解决了报错，还能把超复杂多层嵌套其实就是一个 string stream 的类型简化为

> std::pin::Pin<Box<dyn Stream<Item = Result<String, std::io::Error>> + Send>>
