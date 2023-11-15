# [为什么TLS不能split](/2023/11/why_tls_can_not_split.md)

当我试图将 ws-tool 同步版本改成 rustls_connect 之后就报错 tls 版本不能 split 成读写两个 socket，作者的答复是

> 加上tls后, read/write其实需要同步, 所以之前的split方法都不管用 https://github.com/tokio-rs/tls/issues/40

```
error[E0599]: the method `split` exists for struct `FrameCodec<StreamOwned<ClientConnection, TcpStream>>`, but its trait bounds were not satisfied
   --> exchanges/src/gate_swap/ws_test.rs:19:33
    |
19  |     let (mut w, mut r) = stream.split();
    |                                 ^^^^^ method cannot be called due to unsatisfied trait bounds
    |
   ::: /home/w/.cargo/registry/src/rsproxy.cn-8f6827c7555bfaf8/rustls-0.20.9/src/stream.rs:154:1
```

```
然而，当WebSocket连接升级为TLS/SSL（即wss://），情况就变得复杂了。TLS/SSL协议不仅仅是在数据传输中加入了加密，它还引入了多个涉及握手、密钥交换、数据完整性校验和加密解密等复杂过程的状态。在这种情况下，使用SSL库（如OpenSSL）管理的socket连接不仅仅是普通的文件描述符，它还包括了多个与SSL相关的状态和数据结构，这些数据结构必须同时维护加密状态和socket状态。

如果你尝试通过dup复制文件描述符来分离加密的WebSocket连接的读写操作，问题在于：

SSL状态不会被复制：dup只能复制文件描述符，但是SSL的状态、缓冲区以及与当前加密状态相对应的各种参数和信息是不会被复制的。这意味着新的文件描述符没有必要的SSL上下文来正确处理加密数据。

并发问题：即便理论上可以复制SSL状态（这在实践中是不可能的，而且也不推荐这么做），处理TLS/SSL协议的读写操作通常需要在单一的逻辑流程中协调，因为加密和解密的状态是相互依赖的。尝试在不同的上下文中同时读写同一个SSL连接可能导致竞态条件和数据不一致。

协议要求：TLS/SSL协议要求在数据交换期间维持一定的顺序和完整性。因此，SSL的读写操作需要在一个协调的环境中处理，确保数据以正确的顺序被加密、传输和解密。

总的来说，由于这些问题，对于基于TLS/SSL的连接，最好的做法是在同一个上下文（即使用相同的SSL结构）中串行化地处理所有的读写操作，以保持加密会话的完整性和安全性。如果你需要提高性能或并发性，可以考虑使用异步I/O操作或者在更高的层面（如应用逻辑层）上实现并行处理，而不是在底层传输层分离读写操作。
```

---

考虑 WebSocket 大部分用途都是只读其实也不需要全双工，可能就需要定时发一个 Ping 去 keepalive 维持业务层的心跳

例如业务方要求15秒发一个Ping 每次收消息就更新下上次心跳时间戳(time() 函数走 vdso 用户态系统调用就 1ns)

**设置 read_timeout** timeout 的时候说明长时间服务器没有推消息需要发一个Ping去 keepalive

```Rust
if let tungstenite::stream::MaybeTlsStream::Rustls(stream) = ws.get_mut() {
    stream
        .get_mut()
        .set_read_timeout(Some(Duration::from_secs(15)))?;
} else {
    unreachable!()
}
```

总的来说加上 TLS 之后读写需要"串行" 没法用 socket dup/try_clone 的办法读写分离实现全双工，tokio tls 也是在tokio::net有一个原子量控制串行
