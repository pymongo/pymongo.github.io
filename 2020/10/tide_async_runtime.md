# [tide的异步运行时](/2020/10/tide_async_runtime.md)

我个人用过Rust社区的actix-web、rocket、tide框架， 我认为学Rust的web框架的话只学routes、app_state、middleware这三板斧，Rust社区的所有Web框架必有这三项内容而且附带了examples供你学习。

能理解每个框架是如何在异步多线程环境下共享不可变和可变的变量，然后自己能写一个所用框架的middleware就算熟悉框架了

actix-web 3.0 + sqlx 0.4时使用Sqlite运行时会panic:

```rust
#[actix_web::main]
async fn main() {
    sqlx::SqlitePool::connect("sqlite://db.sqlite").await.unwrap();
}
```

> can call blocking only when running on the multi-threaded runtime

而pg和mysql的feature则不会，这让我重新认识了actix的runtime，并促进我从actix-web转为tide框架

首先actix的Actor模型的每一个Actor并不是一个线程，actix本身也是单线程的tokio runtime上再次封装

actix-web框架偏重，我学Rust的初衷就是看到actix-web跑分排第一，但实际上性能不如tide，我用tide重构后性能有显著提升

## tide的runtime

Rust中文社区的同学们都很推荐用tide，让我眼前一亮的是tide似乎「不依赖异步运行时」，async-grahql的example是使用smol异步运行时

我实际使用的体验是tokio和async_std和actix的异步运行时都能跑tide

但是tide的线程名字thread 'async-std/runtime'确实叫async-std

如果在tide里使用tokio::sync::timeout去给await设定TIMEOUT，会报错

> thread 'async-std/runtime' panicked at 'there is no timer running, must be called from the context of Tokio runtime'

于是我将所有Lock都改为async-std，runtime也按tide的建议改成async_std::main

但是重要的async-redis库却报错了:

> thread 'async-std/runtime' panicked at 'must be called from the context of Tokio runtime configured with either `basic_scheduler` or `threaded_scheduler`'

这样让我陷入两难的局面: 

1. 换回tokio::main，但是不保证tide,Mutex,async-std::future::timeout能不能在tokio环境下正常工作
2. 坚持使用async_std::main，意味着async-redis要换成redis库，大量redis读写的代码要重写，而且redis库的async-std版本不支持项目需求的「断线重连」机制

于是我在tide的github仓库上搜索`tokio`

翻到了这两个有用的[issue](https://github.com/http-rs/tide/issues/538)

这里tide作者提到可以看async-rs/async-std#804的解决方案

在tide的[Port to Tokio 0.2](https://github.com/http-rs/tide/pull/307)里

作者也提到

> async-std comes with a tokio02 feature flag that makes Tokio play nice with other runtimes

Adds the tokio02 feature flag. 

This forwards to smol's tokio02 feature flag which runs tokio::rt::enter whenever a new thread is created. 

This should allow running async_std::main and having tokio crates just work

feature tokio02让我不必换库重写redis代码，感谢smol的贡献者

所以很多人看好Rust社区未来的异步运行时的终极解决方案是smol，smol异步运行时能兼容async-std和tokio的库

## tide的logger

tide的logger用的了log crate的kv_unstable feature以及另一个create的info!宏，用slog或log4rs是看不到tide丰富的kv信息

用tide推荐捆绑使用的femme logger，或者自己手写一个tide的middleware问题也不大
