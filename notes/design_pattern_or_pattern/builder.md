# Builder design pattern

## 作用

为调用者构造结构体提供便利和可读性，说实话 Rust 的 struct expression 可读性也不比 Builder 设计模式差，如果对外的结构体的所有字段都是 pub 我宁可用 struct expression

## 常见于 Stmt/Expr
- `pub struct xxxBuilder`
- `xxxBuilder::build()`, `xxxBuilder::default()`

## examples

- std::thread::Builder::new().stack_size(1024).spawn(|| {})

## usage suggestions

### bad usage case

如果 Builder 构建的结构体的所有字段都是 pub 则不建议用 Builder 改而用 struct expr 即可

```rust
let pool = ThreadPoolBuilder::new().set_size(11).build();

let pool = ThreadPool {
    size: 11,
    ..Default::default()
};
```

### good usage case

Builder 设计模式适用于以下这种情况结构体部分字段 pub 然后对外暴露 Builder 构造的接口

```rust
#[cfg(test)]
mod a {
    pub(crate) struct ThreadPool {
        pub(crate) size: u8,
        b: u8,
        c: u8,
    }

    impl Default for ThreadPool {
        fn default() -> Self {
            Self { size: 1, b: 2, c: 3 }
        }
    }
}

#[test]
fn feature() {
    use a::ThreadPool;
    // compile error
    let pool = ThreadPool {
        size: 11,
        ..Default::default()
    };
    // compile ok, but look callee must use a mutable binding
    let mut pool = ThreadPool::default();
    pool.size = 11;
}
```
