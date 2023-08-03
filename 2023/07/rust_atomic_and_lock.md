# [Atomic Lock 读书笔记](/2023/07/rust_atomic_and_lock.md)

- eyesore: 眼中钉
- Out-of-Thin-Air: 凭空出现

## park

线程运行时也能调用 unpark 先调用 unpark 再调用 park 会导致 park 没效果，Rust 可能在线程上下文塞入一些 park/unpark 请求队列的上下文

```rust
#[test]
fn run() {
    std::thread::current().unpark();
    std::thread::park();
}
```

Linux 没有 park 这个系统调用，park 的实现实际上通过 futex_wait 系统调用

> unpark requests don’t stack up

PhantomData作用之一，PhantomData<Cell<()>> 加这一个字段可以让结构体不能 Sync, 但是 Cell 可以 Send

a closure is only Send if all of its captures are

## RCU

[Linux RCU](/2023/03/linux_read_copy_update.md)

## arc

[Arc 计数溢出处理](/2023/04/how_arc_handle_ref_count_overflow.rs)

--- 

## 精彩的 atomic 部分来了啊

fetch_add and fetch_sub implement wrapping behavior for overflows

```rust
let num_done = &AtomicUsize::new(0);
let total_time = &AtomicU64::new(0);
let max_time = &AtomicU64::new(0);

thread::scope(|s| { for t in 0..4 {
    s.spawn(move || { // move ref of Atomic
        for i in 0..25 {
            let start = Instant::now();
            process_item(t * 25 + i); // Assuming this takes some time.
            let time_taken = start.elapsed().as_micros() as u64;
            num_done.fetch_add(1, Relaxed);
            total_time.fetch_add(time_taken, Relaxed);
            max_time.fetch_max(time_taken, Relaxed);
        }
    });
}}）
```

> Relaxed memory ordering gives no guarantees about the relative order of operations as seen from another thread, it might even briefly see a new updated value of total_time, while still seeing an old value of num_done

### compare_and_exchange 为什么要传入旧值

为何书中自行实现的 compare_and_exchange 需要传入一个期望的修改前数值入参呢?

> If a was not the same as before, another thread must’ve changed it in the brief moment since we loaded it

原因就是用来检测这个数有没有被其他线程修改过(例如应用于 LazyLock/Once 中), CAS(compare and swap)是通过 compare_exchange 实现的

CAS 原子操作用的很频繁所以做成 CPU 指令: 提供一个旧值和一个新值，如果提供的旧值和当前存储值相等就把新值写入

```rust
unsafe fn atomic_compare_exchange<T: Copy>(
    dst: *mut T,
    old: T,
    new: T,
    success: Ordering,
    failure: Ordering,
) -> Result<T, T> {
    // SAFETY: the caller must uphold the safety contract for `atomic_compare_exchange`.
    let (val: T, ok: bool) = unsafe {
        match (success, failure) {
            (Relaxed, Relaxed) => intrinsics::atomic_cxchg_relaxed_relaxed(dst, old, new),
```

### CAS 的 ABA 问题

如果另一个线程把数值从 A 修改为 B 第二次再修改为 A 则当前线程看到数值仍是期望的旧值 A 无法判定是否有其他线程修改过数

对于数值存储来说 ABA 问题不算什么问题，但如果是 atomic ptr 当前线程无感知其他线程是否修改了指针就很危险

ruby/python 等脚本语言无 atomic 暂不讨论，Java 有 AtomicStampedReference 解决 CAS

而 Rust/C++ 则用 memory Ordering 让使用者根据自身业务的并发情况去调整原子序来解决 ABA 问题

### compare_exchange_weak

区别就是性能更好，但是这个方法有时会误报

### fetch_update

compare_and_exchange loop 可以简写为 fetch_update

```rust
let mut id = NEXT_ID.load(Relaxed);
loop {
    match NEXT_ID.compare_exchange_weak(id, id + 1, Relaxed, Relaxed) {
        Ok(_) => return id,
        Err(v) => id = v,
    }
}

NEXT_ID.fetch_update(Relaxed, Relaxed, |n| n.checked_add(1)).expect("too many IDs!")
```

### memory ordering

The available orderings in Rust are:

- Relaxed ordering: Ordering::Relaxed
- Release and acquire ordering: Ordering::{Release, Acquire, AcqRel}
- Sequentially consistent ordering: Ordering::SeqCst(所有调用方都用 SeqCst 才能保证是严格串行的)

Rust's atomic module includes fewer atomic operations than C++, but it covers all the commonly used ones

#### Relaxed

适用于多线程计数器例如 ID 自增分配器，一千个线程 fetch_add(1) 最终一定会得到 1000

我理解 fetch_add 传入 Relaxed 后 load 和 store 过程都用 Relaxed 进行 compare_exchange 操作

#### load Acquire, store Release | AcqRel?

a happens-before relationship between threads 我的理解是能保证一定顺序

store 操作会被重排到 load 操作之前

The Acquire ordering ensures that any write operation that precedes the current read operation is visible to the current thread. It synchronises the current thread with all threads that have previously performed a Release operation on the same atomic variable.

AcqRel： store and load operations of DATA cannot happen concurrently

#### compare_exchange failure order

```rust
pub fn compare_exchange(&self, expected: i32, new: i32, success_order, failure_order) -> Result<i32, i32> {
    // In reality, the load, comparison and store,
    // all happen as a single atomic operation.
    let v = self.load(failure_order);
    if v == expected {
        // Value is as expected.
        // Replace it and report success.
        self.store(new, success_order);
        Ok(v)
    } else {
        // The value was not as expected.
        // Leave it untouched and report failure.
        Err(v)
    }
}
```

当我尝试将书中第三章的 Locking 例子(100 个线程对同一个字符串做 push 操作)的 fail_order 从 Relaxed 改成 Release

```
error: `compare_exchange`'s failure ordering may not be `Release` or `AcqRel`, since a failed `compare_exchange` does not result in a write
if LOCKED.compare_exchange(false, true, Acquire, Release).is_ok() {
```

这个报错暂时不能理解，只能暂时认知为 CPU 指令不支持这样的操作

### gpt: why Rust no Ordering::consume

because it introduces additional complexity and can lead to subtle bugs. Consume ordering is a weaker form of ordering compared to other memory orderings like acquire and release

Instead, Rust's atomic types support strong memory ordering guarantees such as Acquire, Release, AcqRel, and SeqCst

### 先行发生关系(Happens-Before Relationship)

大意就是代码从上到下逐行执行没有发生编译器重排

### std::sync::atomic::fence

fence prevents the compiler and CPU from reordering certain types of memory operations around it

> more efficient alternative is to instead use relaxed operations in combination with a SeqCst fence

load(Acquire)=load(Relaxed)+fence(Acquire)  
store(Release)=fence(Release)+store(Relaxed)

fence 作用，更细粒度的控制，例如 compare_and_swap 的 success/fail ordering

compiler_fence 和 lib.rs/membarrier 的内容过于抽象暂时跳过

### std::hint::spin_lock

可应用于 busy-wait 的自旋锁，自旋锁优点是延迟低不用 thread park futex_wait

## CondVar impl channel

### pthread_mutex or futex_mutex

condvar/mutex/rwlock 都有 futex 版本，futex 是 linux 特有的系统调用部分函数跟 pthread 重合

futex is user-spaces version of pthread

### futex 的三个同步原语

wait() function might return spuriously, without a corresponding wake operation

由于 wait 可能伪造的结束，一般用法都是结合循环使用 while load()==UNLOCK { wait() }

- wait(state: &AtomicU32, val: u32): wait unti state != val
- wake_one(&AtomicU32): 
- wake_all(&AtomicU32): 

### notify_one 源码

```rust
// /lib/rustlib/src/rust/library/std/src/sys/unix/futex.rs
#[cfg(any(target_os = "linux", target_os = "android"))]
pub fn futex_wake_all(futex: &AtomicU32) {
    let ptr = futex as *const AtomicU32;
    let op = libc::FUTEX_WAKE | libc::FUTEX_PRIVATE_FLAG;
    unsafe {
        libc::syscall(libc::SYS_futex, ptr, op, i32::MAX);
    }
}
```

notify_one 的区别就是 SYS_futex 系统调用最后一个参数传入的是 1 而不是 i32::MAX

channel() tx/rx guaranteeing that cannot end up with multiple copies of either of them, and easy to move tx and rx to different thread

## 标准库 3 种 channel

实际上 channel 的 tx/rx 是同一个结构体，在 tokio oneshot 和书中例子通过 Arc 让 tx/rx 共享同一份数据，并且让 send/recv 方法做成消耗自身所有权的设计来避免重复调用

```rust
pub struct Sender<T> {
    flavor: SenderFlavor<T>,
}
enum SenderFlavor<T> {
    /// Bounded channel based on a preallocated array.
    // mpsc::sync_channel(100)
    Array(counter::Sender<array::Channel<T>>),
    /// Unbounded channel implemented as a linked list.
    // mpsc::channel()
    List(counter::Sender<list::Channel<T>>),
    /// Zero-capacity channel.
    // mpsc::sync_channel(0)
    Zero(counter::Sender<zero::Channel<T>>),
}
```

sync_channel 的行为跟 pipe 类似
- buffer 满的时候发送端会 block until buffer has space
- buffer 空的时候接收端会 block

buffer 大小为零的 channel 也叫 **rendezvous channel** 发送端 send 之后会持续 block 直到消费者接收完消息

```
gpt: does zero size pipe also call rendezvous channel?


No, a zero-size pipe is not the same as a rendezvous channel.

A zero-size pipe refers to a pipe with a zero-size buffer, as mentioned earlier. It allows for immediate data transfer between processes without any buffering or delay. However, it does not necessarily involve any synchronization or coordination between the sender and receiver processes.

On the other hand, a rendezvous channel is a communication mechanism that involves synchronization between two processes. It ensures that the sender and receiver processes meet at a specific point before the data transfer occurs. This synchronization can be achieved using various methods, such as explicit signaling or message passing, to coordinate the communication between the processes.

While both zero-size pipes and rendezvous channels involve inter-process communication, they serve different purposes and have different characteristics.
```

零大小的管道让我联想到 splice/sendfile 这样 zero-copy 的系统调用

### 消息队列/通道/管道有哪些性能指标

- 延迟
- 吞吐量
- 缓冲/削峰填谷

---

## 常用汇编指令

理解处理器原子量工作原理需要学习几个常用的汇编指令

ARM 是精简指令集 Reduced instruction set computer

而 x86_64 是复杂指令集，所以很可能 x86 一个指令就等于 arm 3-4 个指令

RISC 好处是指令简单容易实现，因此 ARM 可以更细粒度控制比 x86 多一个 atomic ordering，在某些场合性能更佳

### relaxed 的汇编跟直接读写一样

### (ARM) ldr: mem->reg

load memory address x0 to register w8

- ARM: `ldr w8, [x0]`
- AT&T: `movl (%rax), %eax`

In x86 assembly syntax, the equivalent instruction is mov [address], register.

mov [eax], edx would store the value in register edx to the 

memory location specified by the address in register eax.

### (ARM) str: reg->mem

store a value from a register into memory

我是这样记忆的

- ldr=ld+r=load=mem->reg
- str=st+r=store=reg->mem

### (x86) xadd

xadd instruction is used for atomic exchange and addition

### ARM wzr register

special wzr register is used, which always contains zero

### x86 lock prefix

单核处理器中 Relaxed 的实现没啥 data race

多核处理器引入了 lock 前缀: allows cores to do useful things while waiting for a certain piece of memory to become available.

fetch_add(Relaxed) 就比普通的 store(Relaxed) 版本的汇编指令多了个 lock 前缀

### lock cmpxchg

cmpxchg 通常结合 jne 指令一起用，效果等同于 Rust 代码 compare_and_exchange 因其他线程修改过值导致 CAS 失败则会触发 jne

### ARM LL/SC

- LL=load-linked, mem->reg and marks the memory location as "linked"
- SC=store-conditional, reg->mem if the memory location is still "linked"

If another processor or thread modified the memory location in the meantime, the link will be broken, and the SC instruction will fail. we can retry

in ARM architecture, the SC (Store-Conditional) instruction can fail with a false negative result. This means that the SC instruction may fail even though the memory location is still marked as "linked"

错报的原因可能是: interrupt,memory conficlt,memory ordering

### ARM ldxr/stxr

compare and exchange 版本的 ldr/str

- str 是 store 寄存器
- stxr 是 store exclusive 寄存器
- stlr 是 store-release 寄存器
- stlxr 是 store-release exclusive 寄存器

### ARM dmb

dmb = Data Memory Barrier

### Rust 编译器暂时无法优化 compare-and-exchange 循环

因此尽量用 fetch_and_modify 循环而非 compare_and_exchange

> dedicated fetch-and-modify methods rather than a compare-and-exchange loop

---

## CPU cache Coherence

主要有两种处理器缓存一致性的协议

### write-through protocol

读操作有缓存，写操作不会被缓存直接发到下一层(例如 L3 的写操作直接发到 L2)

### MESI

MESI aka Modified Exclusive Shared Invalid

> request for an address it has not yet cached, also called a cache miss, it does not immediately request it from the next layer

---

std::hint::black_box 放在空循环内可以避免编译器去掉无用的循环

## x86 和 ARM 内存序的不一样

x86 上 SeqCst 操作更昂贵，其他几个的汇编都一样, 意味着只有 fence(SeqCst) 会生成 mfence 汇编其他几个 fence 都无事发生

ARM 上 除了 Relaxed 是一份汇编代码，其他几个操作的汇编都一样

意味着 x86 上不小心写错成 load_relaxed+store_release 转成汇编会获得等同于 load_acquire+store_release 语义从而避免了错误

所以很可能 x86 上无 data race 的代码移植到 ARM 上就有问题

x86 这样自动会用/最低的内存序都是 AcqRel 的也就也被称为 strong ordered

memory order: x86 is strongly ordered architectures, ARM is weak

## 线程优先级反转

高优先级线程在低优先级线程持有的锁上被阻塞的问题，导致高优先级线程实际上还要等低优先级线程

## 线程优先级继承

解决办法是当线程持有锁的时候临时性提高该线程的优先级，提高到持有该锁的所有线程的优先级的最高值

> blocking thread inherits the priority of the highest priority thread that is waiting for it, temporarily increasing the priority

---

## CondVar::notify 惊群问题

after waking up, all those threads will immediately try to lock the same mutex. Most likely, only one thread will succeed, and all the others will have to go back to sleep

## RwLock 写锁惊群浪费 CPU 问题

不断有读锁数量发生变化，但唤醒写锁等待线程后发现还有读锁只能继续 sleep 如此反复浪费 CPU

## RwLock 写锁 Starvation 问题

不断有读锁获取释放，导致写锁一直无法获取，解决办法是发现有一个写锁等待后就要 block 后面所有读锁获取

书中的实现是 state 为偶数就是全是读锁，只要有一个写锁在等待就变成奇数阻塞后面读锁获取

所以说读写锁基本上是全书中最复杂的实现和最复杂的锁了

---

## 冒险指针

hazard pointers 类似引用计数，适用于读多写少场合

## parking_lot's deadlock_detection feature

tokio 开 parking_lot feature, 然后 parking_lot 再开死锁检测就能检测死锁?

```rust
use parking_lot::RwLock;
let t = std::thread::spawn(|| {
    let x = RwLock::new(1);
    let r = x.read();
    let w = x.write();
});
unsafe { libc::sleep(1); }
let dead_locks = parking_lot::deadlock::check_deadlock();
dbg!(dead_locks[0][0].backtrace());
t.join().unwrap();
```

确实能检测出死锁的线程个数，但是 backtrace 上找不到自己的代码
