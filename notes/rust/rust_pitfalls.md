# Rust缺陷或缺陷

## 缺点.不能处理内存分配失败的情况

或者说内存分配器有待改善

## 缺点.过度依赖宏

宏带来可读性差、静态检查等问题，现阶段IDE不支持宏的语法高亮等

## 缺点.过于复杂的生命周期嵌套+组合

## 编译速度太慢

可能的解决方案: crate以二进制的形式进行分发

```
+ 这样一次link就够了，有人说增量编译慢大部分时间都在link，linker好像是单线程的
- 二进制分发很难针对极其进行优化
- Rust的泛型没法进行二进制分发，只要带<T>或impl就不能只分发二进制，要和调用代码一起联合编译
```

Rust多数库和C++的header-only library更像

## trait语法缺陷

### GAT问题

直到1.50 nightly版才终于能在trait中定义关联类型

### trait的孤儿规则

导致很多时候都需要对第三方库例如Db结构体再包一层，才能添加一些自定义的方法

孤儿规则既保护了上游库的trait/结构体不会被下游的调用库篡改，但是也导致了要多包一层这样的冗余代码

### trait不可重叠规则

例如想给10个结构体实现trait A的默认方法，剩余两个类型再单独实现，有点像OOP的override

## 语法缺陷(其它)

### NLL问题

Non-Lexical Lifetimes (NLL): 非词法作用域生命周期

举例子:

```rust
fn main() {
    let mut scores = vec![1, 2, 3];
    let score = &scores[0];
    scores.push(4);
}
```

```
error[E0502]: cannot borrow `scores` as mutable because it is also borrowed as immutable
 --> src/main.rs:4:5
  |
3 |     let score = &scores[0];
  |                  ------ immutable borrow occurs here
4 |     scores.push(4);
  |     ^^^^^^ mutable borrow occurs here
5 | }
  | - immutable borrow ends here
```

代码里的score明明没有用到，为什么不让借用，因为编译器堆score的作用域检查理解的是main函数的score内

现在可以在nightly中使用`#![feature(nll)]`去启用nll

还有一个例子撮合引擎的订单优先队列中，我的&mut orders和orders.peek_mut()两个指针「不能同时出现」，可能我只是改了堆顶订单，没有修改堆，但是编译器不允许

所以现阶段我只能先将堆顶订单弹出后才能操作

再举一个NLL问题的例子:

```rust
let x = "a".to_string();
let z;
let y = "bb".to_string();
z = longer(&x, &y);
```

由于z借用了y，所以z的生命周期必须比出借方y短，但实际上xyz在同一个作用域，原因是Rust借用的检查机制

## async缺陷

### 不支持async Trait

Actor的trait方法(例如handle)都是同步的，要用些actix黑科技才能在同步方法内执行异步操作

### 异步生态分裂

tokio和async_std，最近的改善是async_std底层使用smol，smol有个tokio02和tokio03的feature能让依赖tokio的异步库正常运行

我的经验是async_std的库一般也能在tokio runtime中运行，tokio的库在smol开tokio02 flag以后也能正常运行

### tokio 0.2和0.3之间不兼容

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
