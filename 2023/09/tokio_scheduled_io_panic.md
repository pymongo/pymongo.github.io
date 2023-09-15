# [tokio ScheduledIo panic](/2023/09/tokio_scheduled_io_panic.md)

```
thread 'tokio-runtime-worker' panicked at 'assertion failed: `(left == right)`
  left: `0`,
 right: `1`', /root/.cargo/registry/src/rsproxy.cn-8f6827c7555bfaf8/tokio-1.32.0/src/runtime/io/scheduled_io.rs:220:9
stack backtrace:
   0: rust_begin_unwind
             at /rustc/d59363ad0b6391b7fc5bbb02c9ccf9300eef3753/library/std/src/panicking.rs:593:5
   1: core::panicking::panic_fmt
             at /rustc/d59363ad0b6391b7fc5bbb02c9ccf9300eef3753/library/core/src/panicking.rs:67:14
   2: core::panicking::assert_failed_inner
   3: core::panicking::assert_failed
   4: tokio::runtime::io::scheduled_io::ScheduledIo::set_readiness
   5: tokio::runtime::io::scheduled_io::ScheduledIo::clear_readiness
   6: tokio::runtime::io::registration::Registration::clear_readiness
   7: tokio::runtime::io::registration::Registration::try_io
   8: tokio::net::tcp::stream::TcpStream::try_read_buf
   9: sqlx_core::rt::rt_tokio::socket::<impl sqlx_core::net::socket::Socket for tokio::net::tcp::stream::TcpStream>::try_read
  10: <alloc::boxed::Box<S> as sqlx_core::net::socket::Socket>::try_read
  11: <sqlx_core::net::socket::Read<S,B> as core::future::future::Future>::poll
  12: sqlx_core::net::socket::buffered::ReadBuffer::read::{{closure}}
  13: sqlx_core::net::socket::buffered::BufferedSocket<S>::read_buffered::{{closure}}
  14: sqlx_core::net::socket::buffered::BufferedSocket<S>::read_with::{{closure}}
  15: sqlx_core::net::socket::buffered::BufferedSocket<S>::read::{{closure}}
  16: sqlx_postgres::connection::stream::PgStream::recv_unchecked::{{closure}}
```

再看看 panic 位置的源码 runtime/io/scheduled_io.rs:220

```rust
impl ScheduledIo {
    /// Sets the readiness on this `ScheduledIo` by invoking the given closure on
    /// the current value, returning the previous readiness value.
    ///
    /// # Arguments
    /// - `tick`: whether setting the tick or trying to clear readiness for a
    ///    specific tick.
    /// - `f`: a closure returning a new readiness value given the previous
    ///   readiness.
    pub(super) fn set_readiness(&self, tick: Tick, f: impl Fn(Ready) -> Ready) {
        let mut current = self.readiness.load(Acquire);

        // The shutdown bit should not be set
        debug_assert_eq!(0, SHUTDOWN.unpack(current));
        // ...
    }
}
```

这个 panic 在应用程序启动 tokio 依赖数据库的定时后台任务后百分百复现，这个后台任务用到了以下 `Lazy<DbPool>` 的定义

```rust
pub static DB_POOL: Lazy<DbPool> = Lazy::new(|| {
    std::thread::spawn(|| {
        let rt = tokio::runtime::Builder::new_current_thread()
            .enable_all()
            .build()
            .unwrap();
        rt.block_on(init_db_pool())
    })
    .join()
    .unwrap()
});
```

我大胆猜测 sqlx 连接池因为在新线程中创建的 runtime 中初始化的，这个连接池里面的 Future 上下文应该有新线程的上下文

因此用 main 函数的 runtime 去 poll 的时其实就像 sqlx 的 Future 从一个 runtime 转移到另一个 runtime 中，原先记录在上下文中的线程状态转移到另一个 runtime 就会乱套了，上下文的线程状态没对上所以触发 debug_assert panic

虽说 thread::spawn+rt::new_current_thread 可以绕过 `Cannot start a runtime from within a runtime` 的限制且在同步函数中执行异步代码，但这种同步跑异步的办法只适合 reqwest 执行一个 HTTP 请求这样无状态的，并不适合 sqlx 连接池这种有状态的

于是我改成以下方式，用单线程不断轮询的 futures::executor::block_on 执行异步代码，不再 runtime 内创建 runtime 而是获取当前 runtime 去初始化 sqlx

```rust
pub static DB_POOL: Lazy<DbPool> = Lazy::new(|| {
    futures::executor::block_on(async {
        let rt = tokio::runtime::Handle::try_current().unwrap();
        rt.spawn(init_db_pool()).await.unwrap()
    })
});
```

问题就解决了，不知道我之前遇到 sqlx Pool timeout 的问题是不是也跟这个有关

# sqlx openEuler bug

然后虽然在 Ubuntu 20.04 和 Ubuntu 22.04 没问题，但是在 `openEuler 22.03` 上面就 panic 了

!> thread 'tokio-runtime-worker' panicked at 'called `Result::unwrap()` on an `Err` value: Protocol("unexpected response from SSLRequest: 0x00")', /home/wuaoxiang/IDP/crates/sqlx/src/lib.rs:42:10

sqlx::pool::PoolOptions::connect 方法我 unwrap 的报错

换成 tokio::sync::OnceCell 也没用

## step to reproduce

```
docker run --rm --name postgres -p5432:5432 -v /var/lib/postgresql/data --tmpfs=/var/lib/postgresql/data -e POSTGRES_HOST_AUTH_METHOD=trust postgres
```

> docker run -it --net=host openeuler/openeuler:22.03-lts-sp2

好吧复现失败了，跟同事沟通才发现，欧拉系统的部署环境在 5432 端口启动了另一个国产数据库(信创纯国产环境)不是 postgres 协议，所以 postgres 协议解析失败是正常的
