# [async fn的展开写法](/2020/07/async_fn.md)

一个Rust应用里可能会有一个线程去轮询某些工作(例如每隔一秒推送一次行情最新价格)

我习惯用tokio::spawn去实现，tokio::spawn的入参是一个async的代码块

为了拆分代码，我定义了一个函数去返回async的代码块

```rust
// this function can be simplified using the `async fn` syntax
pub fn run_interval() -> impl Future<Output = ()>  {
    async {
        let mut interval = tokio::time::interval(std::time::Duration::from_secs(1));
        loop {
            let time: NaiveTime = chrono::Local::now().time();
            let now = NaiveTime::from_hms(time.hour(), time.minute(), time.second());
            dbg!(now);
            interval.tick().await;
        }
    }
}

tokio::spawn(run_interval());
```

但是运行cargo clippy时提示:

> fn run_interval() -> impl Future<Output = ()> can be simplified using the `async fn` syntax

```rust
pub async fn run_interval() {
    let mut interval = tokio::time::interval(std::time::Duration::from_secs(1));
    loop {
        let time: NaiveTime = chrono::Local::now().time();
        let now = NaiveTime::from_hms(time.hour(), time.minute(), time.second());
        dbg!(now);
        interval.tick().await;
    }
}
```

还是看看spawn的源码加深下理解吧

```rust
pub fn spawn<T>(task: T) -> JoinHandle<T::Output>
where
    T: Future + Send + 'static,
    T::Output: Send + 'static,
```

原来async fn的返回值就已经impl了Future，以前用 async fn 这种简写的写法时，没仔细研究

所以可以下一个结论? 所有async fn的函数本质上也是一个返回async代码块的函数
