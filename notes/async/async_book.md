# async book读书笔记

The asynchronous Rust ecosystem has undergone(经历undergo的过去分词, the past participle of undergo) a lot of evolution(进化) over time,

so it can be hard to know what libraries to invest(投资，这里指的应该是什么异步库值得投入学习) in ...

in the midst of migrating to the newly-stabilized API(整个异步生态正在向新的已经稳定的async/await API去迁移)

## async/await primer

Unlike futures::executor::block_on, .await doesn't block current thread, but instead asynchronously waits for the future to complete

### futures::join!

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

若是面试中被问及虚函数表的用处，可以答除了dyn动态分发用到虚函数表，还有Future的Context中的waker内也用到了vtable

### waker of Future

先看官方async-book中2.1节给出的Future简化版

```rust
trait SimpleFuture {
    type Output;
    fn poll(&mut self, wake: fn()) -> Poll<Self::Output>;
}

pub struct SocketRead<'a> {
    socket: &'a Socket,
}

impl SimpleFuture for SocketRead<'_> {
    type Output = Vec<u8>;

    fn poll(&mut self, wake: fn()) -> Poll<Self::Output> {
        if self.socket.has_data_to_read() {
            // The socket has data: read it into a buffer and return it.
            Poll::Ready(self.socket.read_buf())
        } else {
            // The socket does not yet have data:
            // Arrange for `wake` to be called once data is available.
            // When data becomes available, `wake` will be called, and the
            // user of this `Future` will know to call `poll` again and
            // receive data.
            self.socket.set_readable_callback(wake);
            Poll::Pending
        }
    }
}
```

If the future is not able to complete yet, it returns Poll::Pending and arranges for the wake() function to be called when the Future is ready to make more progress.

理解: 如果Future是Pending状态，会将wake()函数提供给IO事件(例如socket)，这个waker有点类似"自引用"但又不是，

假如socket来数据了，socket的readable_callback内调用wake，通过wake找到Future自身，再告诉executor可以进行poll

以下是基于SimpleFuture的多个Future并发执行的复合Future

```rust
pub struct Join<FutureA, FutureB> {
    // If the future has already completed, the field is set to `None`.
    // This prevents us from polling a future after it has completed, which
    // would violate(违反) the contract(合同) of the `Future` trait.
    a: Option<FutureA>,
    b: Option<FutureB>,
}

impl<FutureA, FutureB> SimpleFuture for Join<FutureA, FutureB>
where
    FutureA: SimpleFuture<Output = ()>,
    FutureB: SimpleFuture<Output = ()>,
{
    type Output = ();
    fn poll(&mut self, wake: fn()) -> Poll<Self::Output> {
        // Attempt to complete FutureA.
        if let Some(a) = &mut self.a {
            if let Poll::Ready(()) = a.poll(wake) {
                self.a = None; // or self.a.take();
            }
        }
        // Attempt to complete FutureB...

        if self.a.is_none() && self.b.is_none() {
            Poll::Ready(())
        } else {
            Poll::Pending
        }
    }
}
```

在SimpleFuture中，wake是一个fn指针，并不能让executor去区分该调用哪一个waker，fn pointer不能携带数据，所以要将waker加上数据域包装成Context

Waker provides a wake() method that can be used to tell the executor that the associated task should be awoken,

and its future should be polled again.

## futures::select!

和join!不一样，select!只要有其中一个future跑完就可以选择是否退出或继续，

建议用try_join!，这样的话只要有一个Future报错就会提前结束，但是所有Future错误类型必须一样

可以用.map_err or .err_into to consolidate(合并) the error types

```rust
use futures::{future, select};

async fn count() {
    let mut a_fut = future::ready(4);
    let mut b_fut = future::ready(6);
    let mut total = 0;

    // select!的经典用法，直到a和b都跑完才
    loop {
        select! {
            a = a_fut => total += a,
            complete => break,
            default => println!("b is not matched"),
        };
    }
    assert_eq!(total, 10);
}
```

loop select!中还可以循环中继续塞入新的Future

### fuse

select!的Future要实现Unpin和FusedFutures

因为select!会取&mut引用，所以要Unpin

```rust
let t1 = async_fn_1().fuse();
let t2 = async_fn_2().fuse();

pin_mut!(t1, t2);

select! {
    () = t1 => println!("task one completed first"),
    () = t2 => println!("task two completed first"),
}
```
### FusedFuture

FusedFuture: A future can't not poll after complete

FusedFuture使得已经complete的Future在select!宏中不能再被poll(这跟fuse保险丝/熔断这个单词似乎关系不大)

FusedFuture还有一个作用是通过terminated相关的API可以做到在loop select!中塞入新的Future

知识关联: std::iter::Fuse的作用是next()遇到None之后就会停住，跟FusedFuture不太一样

### FuturesUnordered

~~FuturesUnordered: many copies of the same future? need to be run simultaneously~~

还没用

## 递归Future

async fn并不能递归调用，可以转为普通函数然后返回值是BoxFuture

```rust
use futures::future::{BoxFuture, FutureExt};

fn recursive() -> BoxFuture<'static, ()> {
    async move {
        recursive().await;
        recursive().await;
    }.boxed()
}
```

## async-trait

如果方法频繁调用，尽量不要用async-trait，会有额外的开销

