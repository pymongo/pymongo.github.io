# [tracing mem leak review](/2022/07/tracing_span_cross_await_memory_leak_review.md)

Rust 社区推荐了 tracing 使用不当造成 OOM 的文章: https://onesignal.com/blog/solving-memory-leaks-in-rust/

特此写篇此文的读后感(review/book review)

让我想起之前想让过程宏注入 span.enter 给每一个函数实现 tracing::instrument 结果导致无限递归套娃日志文件刷爆硬盘

(因为不能在一个过程宏中给 item 加一个新的属性宏 `#[tracing::instrument]`)

也是同事提醒我 tracing 的 span 在异步函数必须确保 span.enter() 之后会不会 span.leave() 保证 span 不会灾难般无限堆叠

onesignal 的项目中遇到了 rust 进程周期性的 OOM kill 从 prometheus 监控数据看内存使用量的时序图会有明显的锯齿波

文章摘要说了是 tracing 的使用不当导致 OOM, 然后进程被 kill 之后被 supervisor/systemd 之类的 daemon 拉起然后运行一段时间后又 OOM

---

文中讲述了 tracing span 在异步函数执行时 span guard 没有 drop 回收导致 OOM，毕竟 await 可能会跨线程执行

TODO 文中解释 span 不能跨 await 的篇幅过短抽象的太简单我也没能看懂

解决办法是 异步函数内不要/不能写 span.enter 转而写 Future.instrument 让 span 的析构函数绑定在 Future 上跟 Future 同生命周期

**最后 onesight 团队给 clippy 提 PR 新增 lint 检测**

所以我可以把以下内容加到 clippy.toml 去规避:

```toml
await-holding-invalid-types = [
    # https://onesignal.com/blog/solving-memory-leaks-in-rust/
    "tracing::trace::Entered",
    "tracing::trace::EnteredSpan",
    # https://github.com/seanmonstar/reqwest/issues/1017
    "reqwest::blocking::Client"
]
```
