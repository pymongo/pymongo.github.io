# [Stream::try_clone](/2022/08/stream_try_clone.md)

读 ra 的 lsp-server 源码时学到了 Stream::try_clone

因为 Rust 的 stream 读写都要可变引用相当于互斥锁，导致难以同时读+写
要么 select 调用 IO 多路复用例如 tokio::io::split
要么 stream.try_clone (走 dup 系统调用)

发现 ra 多 dup 了一次 TCP 的 fd 于是提了个 PR 希望启动速度能快一些

- <https://twitter.com/ospopen/status/1561606558601326592>
- <https://github.com/rust-lang/rust-analyzer/pull/13078>
