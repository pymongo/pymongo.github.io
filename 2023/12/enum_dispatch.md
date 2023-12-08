# [enum_dispatch与缓存命中](/2023/12/enum_dispatch.md)

在运行 enum_dispatch 的 benchmark 的时候我发现一个很有意思，运行源码中默认的 bench trait 有一个方法，每次迭代两个 variant 都调用一次

```
test benches::boxdyn_blackbox       ... bench:     225,386 ns/iter (+/- 14,061)
test benches::enumdispatch_blackbox ... bench:     279,590 ns/iter (+/- 91,416)

test benches::boxdyn_homogeneous_vec       ... bench:   3,488,651 ns/iter (+/- 322,595)
test benches::enumdispatch_homogeneous_vec ... bench:     273,401 ns/iter (+/- 14,862)
```

一次 iter 一百万次调用，vec 测试中长度为 1024 但也是一百万次调用

可见 Vec Box dyn 默认情况下性能甚至更好，但  Vec Box dyn 性能骤降应该是缓存命中问题

> 索引vtable的速度是O(1)，但动态分发仍然有一定的性能开销。这是因为它需要额外的内存访问（获取vtable和函数指针），并且可能对现代CPU的预测分支优化（branch prediction）造成不利影响

试试看把 trait/vtable 的函数数量增加到12个，结果enum_dispatch跟box dyn的性能差距被拉近

```
test benches::boxdyn_blackbox       ... bench:     219,917 ns/iter (+/- 19,326)
test benches::enumdispatch_blackbox ... bench:     222,376 ns/iter (+/- 12,845)
```

```rust
#[enum_dispatch]
pub trait ReturnsValue {
    fn return_value(&self) -> usize;
    fn r1(&self) -> i32;
    fn r2(&self) -> i32;
    fn r3(&self) -> i32;
    fn r4(&self) -> i32;
    fn r5(&self) -> i32;
    fn r6(&self) -> i32;
    fn r7(&self) -> i32;
    fn r8(&self) -> i32;
    fn r9(&self) -> i32;
    fn r10(&self) -> i32;
}

fn boxdyn_blackbox(b: &mut Bencher) {
    let dis0: Box<dyn ReturnsValue> = Box::new(Zero);
    let dis1: Box<dyn ReturnsValue> = Box::new(One);

    b.iter(|| {
        for _ in 0..ITERATIONS {
            test::black_box(dis0.return_value());
            test::black_box(dis0.r3());
            test::black_box(dis0.r6());
            test::black_box(dis0.r9());
            test::black_box(dis1.return_value());
            test::black_box(dis1.r3());
            test::black_box(dis1.r6());
            test::black_box(dis1.r9());
        }
    })
}
```

结果当每次迭代访问虚表不同的方法数量变多后，box dyn性能就比静态分发慢一个数量级，应该是分支预测和cpu缓存命中率都下降了

```
test benches::boxdyn_blackbox       ... bench:   6,918,933 ns/iter (+/- 456,640)
test benches::enumdispatch_blackbox ... bench:     901,027 ns/iter (+/- 124,013)
```

结论就是封闭生态的应用例如公司内同一个cargo workspace下面的trait的全部实现，可以用enum_dispatch静态分发加速，对于开放生态的公共库还是暴露 box dyn 的接口更佳
