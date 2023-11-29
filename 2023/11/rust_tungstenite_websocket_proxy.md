# [Rust WS 代理与压缩](/2023/11/rust_tungstenite_websocket_proxy.md)

由于用的aws云主机是流量计费的且数据库占云主机太多内存，我萌生出本地台式机用ws采集行情数据的想法，可就币安需要开代理才能连ws

朋友说python websocket-client开代理很简单就一个配置完事，怎么到了 Rust 这边最火的 ws 库 tungstenite 既不能开代理也不能开 permessage-deflate 压缩像个原始人一样

目前就 ws-tool, ws-rs 支持消息压缩，但没有一个库支持 proxy 可能是被类型体操限制了，那我就拿 tung 试试看

```rust
let ws_uri = url::Url::parse("wss://fstream.binance.com/stream?streams=!bookTicker").unwrap();
let host = ws_uri.host().unwrap().to_string();
let host = host.as_str();

let socks_stream = match Socks5Stream::connect(proxy_addr, (host, 443)) {
    Ok(stream) => stream,
    Err(e) => {
        eprintln!("Failed to connect to SOCKS5 proxy: {:?}", e);
        return;
    }
};

let mut tcp_stream = socks_stream.into_inner();
tcp_stream.set_read_timeout(Some(std::time::Duration::from_secs(5))).unwrap();

let mut root_store = rustls::RootCertStore::empty();
root_store.add_trust_anchors(webpki_roots::TLS_SERVER_ROOTS.iter().map(|ta| {
    rustls::OwnedTrustAnchor::from_subject_spki_name_constraints(
        ta.subject,
        ta.spki,
        ta.name_constraints,
    )
}));
let mut config = rustls::ClientConfig::builder()
    .with_safe_defaults()
    .with_root_certificates(root_store)
    .with_no_client_auth();
let mut conn = rustls::ClientConnection::new(Arc::new(config), host.try_into().unwrap()).unwrap();

let mut tls_stream = rustls::Stream::new(&mut conn, &mut tcp_stream);

let mut req = ws_uri.into_client_request().unwrap();
// 别加消息压缩的header否则tung解析不了消息
// req.headers_mut().insert("Sec-WebSocket-Extensions", HeaderValue::from_static("permessage-deflate;client_max_window_bits=15;server_max_window_bits=15"));
println!("req_header = {:#?}", req.headers());
let (mut websocket, response) = match client(req, tls_stream) {
    Ok((ws, response)) => (ws, response),
    Err(e) => {
        eprintln!("Failed to create WebSocket client: {:?}", e);
        return;
    }
};
```

经过 gpt4 友好提示很快理解到标准库 TcpStream 用代理库 socks 包一层，然后用 rustls Stream 包一层，最后传入到 tung 大致是这样的抽象

但是踩坑的地方在于 rustls 的 api 变动的很频繁，我让 gpt4-turbo 换着生成几种代码都不能跑，~~甚至 rustls 官方 example 都报错(当然因为是beta版发生了不兼容改动)~~

没办法只好从 tung 抄一个版本 tung="0.20.1", rustls="0.21.9", webpki-roots="0.25.2"

再看 ws-tool 作者的 tung proxy patch `https://github.com/snapview/tungstenite-rs/issues/177` 就跟我的实现差不多了

---

[okx 文档](https://www.okx.com/cn/learn/complete-guide-to-okex-api-v5-upgrade) 都说 ws 支持了 deflate 尤其是行情这样json数据最适合压缩了

最终我还是试着实现了 ws-tool 同步版本的 tls+proxy+deflate 并将自己的踩坑贡献成例子

> https://github.com/PrivateRookie/ws-tool/blob/main/examples/tls_proxy_deflate_client.rs

但是 window_size 设置成 15 币安就会解压缩报错: `error occurred on websocket connection: decompress failed -3`

作者他也不熟悉，回复我:

> libz 的实现和标准的websocket deflate api有些差异, 这些报错我其实也不太清楚。我之前试过纯rust实现的deflate, 但性能或api都不太行, 所以先用libz凑合
