# 异步编程

## async学习资料(我看完的)

- [talking: Rust's Journey to Async/Await](https://www.youtube.com/watch?v=lJ3NC-R3gSI&t=1700s)
- [article: 刀哥Rust学习笔记3: 有栈协程/无栈协程](https://rustcc.cn/article?id=c0c47719-be7f-4298-ab5a-507cb65f9538)
- [article: 刀哥Rust学习笔记4: async/await](https://rustcc.cn/article?id=495f1e25-2ede-46ec-8c85-8fd823f0a8a9)
- [mdbook: official async book](https://rust-lang.github.io/async-book)
- [doc: Trait std::future::Future](https://doc.rust-lang.org/std/future/trait.Future.html)

## async学习资料(接下来看的)

- [mdbook: Green Threads Explained in 200 Lines of Rust](https://cfsamson.gitbook.io/green-threads-explained-in-200-lines-of-rust/)
- [mdbook: Exploring Async Basics with Rust](https://cfsamson.github.io/book-exploring-async-basics/)
- [video: The Why, What, and How of Pinning in Rust(Jon另一个较老的async视频是基于0.2版带Item的Future，建议先看新的async视频)](https://www.youtube.com/watch?v=DkMwYxfSYNQ)

---

## async book读书笔记

The asynchronous Rust ecosystem has undergone(经历undergo的过去分词, the past participle of undergo) a lot of evolution(进化) over time,

so it can be hard to know what libraries to invest(投资，这里指的应该是什么异步库值得投入学习) in ...

in the midst of migrating to the newly-stabilized API(整个异步生态正在向新的已经稳定的async/await API去迁移)

### async/await primer

Unlike futures::executor::block_on, .await doesn't block current thread, but instead asynchronously waits for the future to complete

#### futures::join!

`futures::join!(future1, future2)`, join! can async wait for multiple futures concurrently

If future1 is blocked, future2 will take over(接管) the current thread, if both future 1 and 2 is blocked then fn contains this statement will blocked and yield to executor

## Future trait

先看标准库std::future::Future(省略了attribute macros)

```rust
// std::future::Future
pub trait Future {
    type Output;

    fn poll(self: Pin<&mut Self>, cx: &mut Context<'_>) -> Poll<Self::Output>;
}

// std::task::{Context, Waker, RawWaker}
pub struct Context<'a> {
    waker: &'a Waker,
    _marker: PhantomData<fn(&'a ()) -> &'a ()>,
}

pub struct Waker {
    waker: RawWaker,
}

pub struct RawWaker {
    data: *const (),
    /// Virtual function pointer table that customizes the behavior of this waker.
    vtable: &'static RawWakerVTable,
}
```

### waker of Future


