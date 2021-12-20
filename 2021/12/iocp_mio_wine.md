# [IOCP mio wine](2021/12/iocp_mio_wine.md)

> poll-based model (you can say that it was effectively designed around epoll), while the completion-based one (e.g. io-uring and IOCP, IoRing) with high probability will be the way of doing async in future (especially in the light of Spectre and Meltdown).

https://news.ycombinator.com/item?id=26407395

Q: 可以从mio对于windows的支持找些灵感？(即 completion-based 兼容 poll-based 的设计)

A: mio windows 现在用的是一个叫 wepoll 的技术，原理是利用系统里面的类似 epoll 的一个接口 afd。这个东西是 undocumented api，非常 hacky(让我想起字节让 Go 支持 io_uring 用了 Go 的 undocumented API)

上 wepoll 之前用的是普通的 iocp，不过因为众所周知的原因没法完美适配 rust future 模型，mio 自己会分配缓冲区，完成以后拷贝回去。

比如之前所有用 tokio 的程序在 wine 上都跑不起来了，mio 被痛骂：https://github.com/tokio-rs/mio/issues/1444

可见跨平台不同 IO 模型的兼容 API 设计几乎是不可能的，哪怕 mio 即便牺牲性能抹平 IO model 差异也是有很多 Bug 的

不知道微软 2022+ 准备推出的类似 io_uring 的 IO 会是怎么设计


## monoio 解决了字节的什么问题

字节 service mesh 服务现在用的是 envoy, 你可以理解成跟 nginx 一样的网关/代理服务器

envoy 的性能不太能满足业务的数据量，于是用 Rust 基于 monoio 打造下一代高性能的 service mesh 框架




## monoio 上生产环境的一些阻碍

网络基础库 hyper 的 h2 用了一些 hack 会把 Future 的 poll 的上下文换掉，导致 monoio 难以兼容 tokio/hyper 生态




## poll-based IO model (epoll/kqueue), completion-based IO model (io-uring, IOCP, IoRing)

当前 Rust 的 Future 模型基于 poll 其实不太适合 io_uring， 为了抹平兼容 Future 上的差异付出一些性能的开销




## 字节除了飞书还有哪些项目在生产环境用了 Rust

字节内部在大力推进 wasm 上生产的应用，已经有一个 c什么(没听清) 的项目在生产上用 wasmtime+rust




## monoio 将来的目标

打造 monoio 生态， HTTP web server 框架， http1, http2 库， grpc 库 等等。推动 Rust 在其它项目侧的使用