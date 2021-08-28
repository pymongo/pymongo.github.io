# [tonic ipv6 bug](/2021/08/tonic_ipv6_bug.md)

tonic/tonic-build version: 0.4

标准库的 `std::net::ToSocketAddrs::to_socket_addrs(&("localhost", 0)).unwrap().next().unwrap().to_string()` 默认会将 localhost DNS 解析成 Ipv6 地址

tonic 对 ipv6 支持好像不够好，所以走到 unimplemented 代码然后报错

另外出错的原因也可能是 rpc server 端口不存在

<https://github.com/hyperium/tonic/issues/688>

```
thread 'tokio-runtime-worker' panicked at 'called `Result::unwrap()` on an `Err` value: Status { code: Unimplemented, metadata: MetadataMap { headers: {"date": "Fri, 27 Aug 2021 08:37:19 GMT", "content-type": "application/grpc"} } }', /xxx/src/lib.rs:198:86
```

解决方法是 tonic rpc 客户端/服务端都用 IPv4
