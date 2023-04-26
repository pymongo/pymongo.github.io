# [Arc 计数溢出处理](/2023/04/how_arc_handle_ref_count_overflow.rs)

Rc 在当前线程的引用计数为1的时候应该是可以安全的 Send 到第二个线程

但是引用计数是运行时动态的数值编译时无法获取，所以就一揽子打死成不能 Send

Arc 内部用 Ordering::Relax 足以保证多线程读写一个计数器变量的原子性

## Arc 计数溢出处理

由于 atomic fetch_add 溢出时会 wrapping_add 而不是 saturating_add

如果对溢出时 panic 当前线程，由于 atomic 只能先自增再返回旧的值

假如引用计数上限设置成 usize-10 所以第一个线程访问的时候 usize 发现溢出 panic 了，但是第二个线程访问的时候又自增还是 panic

只有线程够多迟早会溢出成 0

```rust
if old_size > MAX_REFCOUNT {
    abort();
}
```

标准库的做法是，发现溢出就 exit(sigabrt) ，当然正常情况下也不可能 clone 几十亿次导致溢出
