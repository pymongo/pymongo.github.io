# [IOCP mio wine](2021/12/iocp_mio_wine.md)

> poll-based model (you can say that it was effectively designed around epoll), while the completion-based one (e.g. io-uring and IOCP) with high probability will be the way of doing async in future (especially in the light of Spectre and Meltdown).

https://news.ycombinator.com/item?id=26407395

Q: 可以从mio对于windows的支持找些灵感？(即 completion-based 兼容 poll-based 的设计)

A: mio windows 现在用的是一个叫 wepoll 的技术，原理是利用系统里面的类似 epoll 的一个接口 afd。这个东西是 undocumented api，非常 hacky

上 wepoll 之前用的是普通的 iocp，不过因为众所周知的原因没法完美适配 rust future 模型，mio 自己会分配缓冲区，完成以后拷贝回去。

比如之前所有用 tokio 的程序在 wine 上都跑不起来了，mio 被痛骂：https://github.com/tokio-rs/mio/issues/1444

可见跨平台不同 IO 模型的兼容 API 设计几乎是不可能的，哪怕 mio 即便牺牲性能抹平 IO model 差异也是有很多 Bug 的
