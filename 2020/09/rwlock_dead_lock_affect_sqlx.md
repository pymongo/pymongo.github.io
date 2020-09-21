# [RwLock死锁导致sqlx卡死](/2020/09/rwlock_dead_lock_affect_sqlx.md)

最近重构Rust项目的代码时，发现运行单元测试时sqlx会卡死在sql语句A的执行上，

甚至卡死的时间超过5分钟，那就肯定不是MySQL的FOR UPDATE悲观锁timeout的问题，因为MySQL锁都有timeout的

我实在没想到出问题的代码在哪，于是就使用逐行注释的方法

把出问题的A给注释掉，结果程序卡死在A的上一条SQL语句

然后我再试试把A的下一段语句注释掉，结果就OK了

原来问题是出在A后面的RwLock获取时发生死锁了，

所以异步可能欺骗了你，明明是RwLock死锁却告诉你sqlx卡死了，由于异步代码运行顺序不确定，所以可能先执行后面的获取RwLock再回来执行sql语句

这可能是异步编程难以Debug的原因，异常的表现是卡死在SQL语句，你以为是sqlx死锁卡住了

实际上是在死锁的上下文(附近的代码)处卡死了，例如我这次遇到的RwLock卡死

```rust
let last_price = LAST_PRICE.get().unwrap().read().await;
if form.price > last_price.upper_limit {
    return Err(anyhow!("price is invalid"));
}
// 这里忘记把RwLock的read_lock给drop掉了
// ...
call_fn_b

// fn_b
sqlx::query("...").await?;
let last_price = LAST_PRICE.get().unwrap().write().await;
```

## await timeout

由于Rust的Mutex/RwLock锁似乎没有自带timeout，所以有必要给每个锁都加上timeout方便Debug哪一行发生死锁了

> let order = tokio::time::timeout(LOCK_TIMEOUT, ORDER.get().unwrap().read()).await.unwrap();

所以设置timeout的思想在做项目中非常有用，例如HTTP请求、微服务调用、获取锁等都要有timeout

例如在游戏《糖豆人》的蜂巢关卡中，掉下最后一层的就会出局，但是如果所有玩家都开了飞天挂，那么游戏将永远不会结束

这样服务器为本局游戏分配的资源就永远不会得到回收，服务器会慢慢耗尽所有资源

所以糖豆人的所有关卡都设有timeout，超过一定时间就自动结束
