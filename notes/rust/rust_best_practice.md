# Rust最佳实践

HashMap缓存不友好(缓存性能不如BTreeMap) 

## 用env::var还是OnceCell共享全局的String变量?

假设env::var是通过dotenv读配置文件再写入到环境变量中，假设环境变量和OnceCell一样只会被写入一次

```
test bench_env_var   ... bench:         255 ns/iter (+/- 16)
test bench_once_cell ... bench:           1 ns/iter (+/- 0)
```

实验表明，用env::var去共享全局的字符串常量，性能比OnceCell慢两个数量级

更好的做法是使用Web框架自带的AppState去共享不可变的字符串

更棒的做法是，如果变量是固定的，你不会让btcusdt和ethusdt两个不同交易对共用一个可执行文件，那么编译前将交易对名称写到配置文件中，build.rs通过rustc-env的方式传递给编译时的常量

使得MARKET_ID可以得到const内联优化，const propagation

## 将toml配置文件反序列化为结构体而不要用dotenv

dotenv类似于Rails的config/application.yml，都是将kv的配置文件信息映射成进程的环境变量

但是最大的问题是，如果配置项发生变动，不能对配置项进行严格的检查，而且配置项读进环境变量后就不管了，也不会删除环境变量释放资源

所以我遇到过多次Rails项目因为新增配置项，而配置文件没有同步改动，导致运行时报错

如果将配置项强制反序列为一个结构体，不仅支持String以外的类型，也支持枚举/Option/结构体嵌套，最大好处是避免了少一个字段或多一个字段

## 语法缺陷(其它)

### NLL问题(1.56 几乎解决了)

Non-Lexical Lifetimes (NLL): 非词法作用域生命周期

撮合引擎的订单优先队列中，我的&mut orders和orders.peek_mut()两个指针「不能同时出现」，可能我只是改了堆顶订单，没有修改堆，但是编译器不允许

## clippy误报或缺陷

### clippy生命周期误报

```rust
impl<'a> MyTrait for MyHandler<'a> {
    fn handle(&mut self, bytes: &[u8]) {}
```

以上代码在clippy中会误报生命周期不能省略

```
warning: explicit lifetimes given in parameter types where they could be elided (or replaced with `'_` if needed by type declaration)
   = note: `#[warn(clippy::needless_lifetimes)]` on by default
   = help: for further information visit https://rust-lang.github.io/rust-clippy/master/index.html#needless_lifetimes
```

要解决这个警告，需要用到一个trick: 改成`fn handle<'b>(&'b mut self, bytes: &[u8])`
