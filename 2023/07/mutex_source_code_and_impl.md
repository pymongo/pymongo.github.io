# [Mutex 源码实现](/2023/07/mutex_source_code_and_impl.md)

看完 Rust Atomic And Locks 后也算手痒也实现下标准库的 Mutex

## futex

考虑到 mutex 更通用所以不能用自旋锁，自旋锁长时间(例如超过一秒) busy-wait 极大浪费 CPU, 自旋锁的优点只适用于能够快速拿到锁的低延迟场合，所以用 futex 阻塞线程来获取锁比较合适 ~~CondVar~~

futex = Linux fast user space mutex, pthread_mutex

书里说在 x86 上自旋锁 100 次轮询的耗时约等于 Mutex 一次加锁/解锁

!> futex 系统调用高并发下偶尔会 errno 11 EAGAIN Resource temporarily unavailable

```rust
/// possible EAGAIN error, would EAGAIN cause futex_wait spurious exit?
fn futex_wait(a: &AtomicU32, expected: u32) {
    unsafe { libc::syscall(
        libc::SYS_futex,
        a,
        libc::FUTEX_WAIT,
        expected,
        std::ptr::null::<libc::timespec>(),
    ); }
}

fn futex_wake_one(a: &AtomicU32) {
    unsafe { libc::syscall(
        libc::SYS_futex,
        a,
        libc::FUTEX_WAKE,
        1,
    ); }
}
```

## 为何锁的状态有三种

如果只有两种状态，MutexGuard drop 的时候到底要不要 wake_one 去唤醒等待中的线程？因为只有 unlock/locked 状态是不够的，还需要区分开 locked_any_thread_waiting 和 lock_no_thread_waiting

```rust
struct MutexState;
impl MutexState {
    const UNLOCK: u32 = 0;
    const LOCKED_NO_OTHER_THREADS_WAITING: u32 = 1;
    // 第三个状态的作用是 drop MutexGuard 的时候判断下是否需要 wake_one
    const LOCKED_ANY_THREAD_WAITING: u32 = 2;
}
```

## 函数定义

```rust
struct MyMutex<T> {
    state: std::sync::atomic::AtomicU32,
    /// use UnsafeCell to return a mutable ref from MutexGuard
    data: std::cell::UnsafeCell<T>,
    // is_poisoned: AtomicBool
}
unsafe impl<T> Sync for MyMutex<T> where T: Send+Sync {}

impl<T> MyMutex<T> {
    fn new(data: T) -> Self { todo!() }
    fn lock(&self) -> MyMutexGuard<T> { todo!() }
}

struct MyMutexGuard<'a, T>(&'a MyMutex<T>);
impl<'a, T> Drop for MyMutexGuard<'a, T> {
    fn drop(&mut self) { todo!() }
}

impl<'a, T> std::ops::Deref for MyMutexGuard<'a, T> {
    type Target = T;
    fn deref(&self) -> &Self::Target { todo!() }
}
impl<'a, T> std::ops::DerefMut for MyMutexGuard<'a, T> {
    fn deref_mut(&mut self) -> &mut Self::Target { todo!() }
}
```

deref/deref_mut 的实现很简单: `unsafe { &mut *self.0.data.get() }`

## 测试代码

```rust
fn main() {
    let mut cnt = MyMutex::new(1);
    std::thread::scope(|s| {
        for _ in 0..5 {
            s.spawn(|| {
                for _ in 0..10000 {
                    let mut x = cnt.lock();
                    *x += 1;
                }
            });
        }
    });
    let data = cnt.lock();
    assert_eq!(*data, 50000);
}
```

## 错误实现示例

```rust
fn lock(&self) -> MyMutexGuard<T> {
    let mut cur = self.state.load(Acquire);
    match self.state.compare_exchange(cur, MutexState::LOCKED_NO_OTHER_THREADS_WAITING, Acquire, Relaxed) {
        Ok(_) => {
            return MyMutexGuard(&self);
        },
        Err(new_cur) => cur = new_cur
    }

    // current state maybe locked_no_wait or locked_any_wait

    // double check state prevent futex_wait spurious exit
    self.state.store(MutexState::LOCKED_ANY_THREAD_WAITING, Release);
    while self.state.load(Acquire) == MutexState::LOCKED_ANY_THREAD_WAITING {
        // if any thread waiting, futex_wait..
        futex_wait(&self.state, MutexState::LOCKED_ANY_THREAD_WAITING);
    }

    MyMutexGuard(&self)
}

fn drop(&mut self) {
    if self.0.state.load(Acquire) == MutexState::LOCKED_ANY_THREAD_WAITING {
        futex_wake_one(&self.0.state);
    }
}
```

我懵逼的是状态一和状态二之间的状态转移应该是怎样的，我的实现乱套了所以每次运行的数值都不一样不等于期望值

错误一: drop 函数内没有将锁状态设置为 unlock, 应该用 swap 设置成 unlock 再判断旧值是否为状态二进行 wake

错误二: compare_exchange 语义理解错了，不需要提前 load 一次，入参一是期望当前值是什么，入参二是如果当前值符合期望则修改成入参二

错误三: while..futex_wait 循环应该是 while swap(2)!=0，当前线程拿到锁之后，swap 成 2 继续阻塞其他等待中线程

## Mutex Starvation

Atomic Locks 书中说读写锁有饥饿问题，我想了下标准库互斥锁也会饥饿

Mutex 释放锁 FUTEX_WAKE 【随机】唤醒一个等待锁的线程去获取锁，
如果某线程等待锁后一直有其他线程频繁获取锁，那这个线程有可能永远都无法获取锁

FairMutex 用队列解决饥饿
tokio Mutex 文档说是 Fair 没说是不是 Reentrant 的

## ReentrantMutex
指的是同一个线程可以重复多次获取同一个锁而不会死锁

---

总结，学完 Rust Atomic And Locks 了解到互斥锁读写锁都有的两个属性: 公平(牺牲性能解决饥饿问题)、可重入(牺牲性能解决单线程死锁)
