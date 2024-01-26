# [reqwest h2 ALPN](/2024/01/reqwest_http2_alpn.md)

reqwest 是 Rust async 最多人用的客户端，可是我最近项目遇到/有人说 http2_prior_knowledge 不符合 RFC <https://github.com/seanmonstar/reqwest/issues/1809>

首先 http2_prior_knowledge 必须要搭配 use_rustls_tls 一起用 <https://github.com/seanmonstar/reqwest/issues/857> 这样就很不好用运行时 http2 就 panic

其次设置了 http2_prior_knowledge() 不会发 ALPN 这个是 TLS 握手的时候判断服务器返回给客户端是否支持 http2

这是开了 use_rustls_tls 的 h2 请求日志

```
24-01-26 10:09:06.707 TRACE hyper::client::pool:639: checkout waiting for idle connection: ("https", api.coinex.com)
24-01-26 10:09:06.707 TRACE hyper::client::connect::http:278: Http::connect; scheme=Some("http"), host=Some("127.0.0.1"), port=Some(Port(10809))
24-01-26 10:09:06.707 DEBUG hyper::client::connect::http:542: connecting to 127.0.0.1:10809
24-01-26 10:09:07.722 DEBUG hyper::client::connect::http:545: connected to 127.0.0.1:10809
24-01-26 10:09:07.793 TRACE hyper::client::client:484: ALPN negotiated h2, updating pool
24-01-26 10:09:07.793 TRACE hyper::client::conn:1007: client handshake Http2
24-01-26 10:09:07.793 TRACE hyper::client::client:509: handshake complete, spawning background dispatcher task
```

这是开了 use_rustls_tls 和 http2_prior_knowledge 的日志

```
24-01-26 10:23:28.472 TRACE hyper::client::pool:639: checkout waiting for idle connection: ("https", api.coinex.com)
24-01-26 10:23:28.472 TRACE hyper::client::connect::http:278: Http::connect; scheme=Some("http"), host=Some("127.0.0.1"), port=Some(Port(10809))
24-01-26 10:23:28.472 DEBUG hyper::client::connect::http:542: connecting to 127.0.0.1:10809
24-01-26 10:23:29.489 DEBUG hyper::client::connect::http:545: connected to 127.0.0.1:10809
24-01-26 10:23:29.558 TRACE hyper::client::conn:1007: client handshake Http2
24-01-26 10:23:29.559 TRACE hyper::client::client:509: handshake complete, spawning background dispatcher task
24-01-26 10:23:29.559 TRACE hyper::client::pool:333: put; add idle connection for ("https", api.coinex.com)
24-01-26 10:23:29.559 DEBUG hyper::client::pool:380: pooling idle connection for ("https", api.coinex.com)
24-01-26 10:23:29.559 TRACE hyper::client::pool:681: checkout dropped for ("https", api.coinex.com)
24-01-26 10:23:29.559 TRACE hyper::client::pool:768: idle interval checking for expired
[coinex_swap/src/rest.rs:593] rsp.version() = HTTP/2.0
```

开启这个配置后，客户端会默认使用 HTTP/2，而不进行 ALPN 协商

各大交易所的普通api都是支持http2的，可是在gate aws colo中curl -vv去看是没有返回ALPN也就是不支持h2的，为了让代码兼容更多情况还是发ALPN吧

性能方面，避免 ALPN 协商可能会减少一些握手阶段的延迟，因为不需要进行协商。这可以在某些情况下提高性能，特别是对于短连接的场景。然而，对于长连接，ALPN 协商的开销相对较小，因为它仅在连接建立时发生一次
