# [Atomic无锁编程](/2020/06/atomic_lock_freedom.md)

今天阅读了几篇「无锁编程」的文章(虽然没怎么看懂，尤其是陈皓写的)，

发现大伙普遍承认Atomic类型的性能比Mutex互斥锁好很多

调研了Java/C++/Rust的Atomic的库后发现

库基本上只提供Atomic的整数类型或布尔值类型

以Rust为例，想用非布尔值非整数的Atomic只能用AtomicPtr

而AtomicPtr用起来要小心，读写可能会陷入unsafe

---

Rust文档中的AtomicPtrExample写法不适用于static作用域

> error[E0658]: references in statics may only refer to immutable values

查阅[资料](https://www.chainnews.com/articles/473753326604.htm)后找到能通过编译的写法

pub static mut WORKDAYS: AtomicPtr<String> = AtomicPtr::new(std::ptr::null_mut());

Write:

```rust
unsafe {
    *WORKDAYS.get_mut() = &mut String::from("test");
}
```

Read:

```rust
println!("[{}]", unsafe { &*WORKDAYS.load(atomic::Ordering::SeqCst) });
```

## 原子序

苦于不懂计算机相关理论，只好将Atomic当RwLock用

读取用Relaxed原子序，写入时用SeqCst原子序

## See Also

- [【翻译】RUST 无锁编程](https://www.chainnews.com/articles/473753326604.htm)
- [Mutex vs Atomic Benchmark](https://www.slideshare.net/mitsunorikomatsu/performance-comparison-of-mutex-rwlock-and-atomic-types-in-rust)
- [【Rust每周一知】Rust中的读写锁RwLock](https://rustcc.cn/article?id=2d51baa8-79e6-4761-adb5-fa2e60393319)
- [Rust的原子(Atomic)型別與記憶體順序(Memory Ordering)](https://magiclen.org/rust-atomic/)