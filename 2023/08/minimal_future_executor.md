# [最小的 Future executor](/2023/08/minimal_future_executor.md)

```rust
fn make_raw_waker() -> std::task::RawWaker {
    std::task::RawWaker::new(std::ptr::null(), &std::task::RawWakerVTable::new(
        |_| make_raw_waker(),
        |_| (),
        |_| (),
        |_| (),
    ))
}
fn main() {
    #[derive(serde::Serialize)]
    struct A;
    
    let waker = unsafe { std::task::Waker::from_raw(make_raw_waker()) };
    let mut context = std::task::Context::from_waker(&waker);

    let mut future = Box::pin(async {
        println!("hello, world!");
    });
    while let std::task::Poll::Pending = std::future::Future::poll(future.as_mut(), &mut context) {}
}
```

<https://stevenbai.top/books-futures-explained/book/> (不知道为啥 xxx explain in 200 lines of Rust 作者删库了，还好有这个中文翻译版本)

## vtable 

dyn trait 胖指针 = data+vtable

vtable = [ptr_of_drop, vtable.len(), 8(alignment), trait::method1, trait::method2, ...]

## struct Pin 和 trait !Unpin

struct Pin 是为了在编译时阻止 自引用结构体-自引用指向的内容被 mem::swap; 可用 PhantomPinned 实现 Unpin

对 Future 来说 Pin 住才能 poll

将一个 !UnPin 的指向栈上的指针固定需要 unsafe
