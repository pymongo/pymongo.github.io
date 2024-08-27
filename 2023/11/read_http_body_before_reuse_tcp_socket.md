# [不读完body就无法复用连接](/2023/11/read_http_body_before_reuse_tcp_socket.md)

用 strace -f -e bind 测试 Rust 几个 http 客户端库能不能复用连接(TCP socket), 为什么strace不抓connect是因为由于转发/重定向的问题会调用多次

reqwest/isahc 循环请求同一接口若干次都能，可是以下 ureq 代码居然建了三次 socket 连接

```rust
fn main() {
    let agent = ureq::AgentBuilder::new().build();
    for _ in 0..3 {
        let rsp = agent.get("https://api.gateio.ws/api/v4/spot/time").call().unwrap();
        assert!(rsp.status() == 200);
    }
}
```

同事说他用ureq包了一个 Python C extension module 库里面倒是可以复用连接，review完代码才发现原来差异是消费了body

同事说 Go 标准库 http.Client 跟 ureq 类似必须显示消费完 body 才能继续复用这个 socket 连接

> 为了使TCP连接能够被复用，http.Response的Body必须被读取到EOF然后关闭。只有这样，http.Transport才会认为这个连接是“干净”的，并将其放回连接池以备后续请求复用

加一行 `rsp.into_string().unwrap();` 就解决了，我猜测 curl/hyper 应该是复用连接前内部隐式的消费了 body

即使调用者没有读取完整的HTTP响应体，libcurl也会在内部确保把剩余的数据“消耗”掉。这通常是通过读取并丢弃剩余数据来完成的

即使在上述情况下，TCP连接似乎可以复用，不读取响应数据并不是一个良好的实践。
