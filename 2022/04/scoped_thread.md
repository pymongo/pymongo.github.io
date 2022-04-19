# [scoped thread](/2022/04/scoped_thread.md)

<https://twitter.com/ospopen/status/1515948777567559682>

听说 Rust 的 Arc(引用计数) 用多了性能很差(用多了可能还不如上 gc 性能好)，
我用 std::thread::scope 去掉了 [the book 哲学家进餐](https://doc.rust-lang.org/1.2.0/book/dining-philosophers.html) 问题的 Arc

```rust
let (table, philosophers) = init_table_and_philosophers();
std::thread::scope(|scope| {
    philosophers.into_iter().for_each(|philosopher| {
        let table = &table;
        scope.spawn(move || {
            philosopher.eat(table);
        });
    });
});
```

scope_thread 为结构化并发提供基石，生命周期上保证子线程一定活的更短(其实是在析构函数中偷偷 join 等待所有子线程结束)

标准库几年前就有 scoped_thread 但因为内存泄漏等 Bug 被删掉，考虑到线程/协程对共享引用的需求越来越大，感谢 Mara Bos 重新把 scoped_thread 实现加回标准库(她年底的新书专门有章讲 scoped_thread)
线程 scoped 有了，什么时候 Future/协程 spawn 才能不要求指针生命周期是 static (不然又要 Arc)
