# 并发编程

Data Race的主要原因是CPU当前时间片执行哪一个线程是不确定的(乱序执行)，所以不同线程对同一块内存进行读写不能保证数据的线程安全

通常可以使用锁(Mutex,RwLock,Spin)、信号量(Semaphores)、屏障(Barrier)和条件变量(Condition Variable)来保证线程同步

自旋锁和互斥锁类似，但是获取失败时会不断轮询而不是让线程休眠

## Semaphores

对资源访问进行计数，有线程访问是信号量-1，如果信号量等于0，则其它线程想访问是只能等待，当线程访问结束后信号量+1

如果信号量只允许是0或1时，效果相当于Mutex

## Sync和Send

Sync: 可以安全地在线程间传递不可变引用

Send: 可以安全地在线程间传递所有权

```rust
pub fn spawn<F, T>(f: F) -> JoinHandle<T>
where
    F: FnOnce() -> T,
    F: Send + 'static,
    T: Send + 'static,
```

'static限定了类型T只能是非引用类型(&'static除外)，因为引用的生命周期要<=出借方

如果引用类型的所有权在线程间传递，生命周期将无法保障/检查，很容易出现悬垂指针

## std::sync::Barrier

通过Barrier让乱序执行的5个线程强行"有序"，5个线程全部执行完前半部分操作后，再开始后半部分操作

例如学校组织同学们去春游或公司团建，必须等班上所有同学都上了大巴车之后，大巴才能发车去下一个景点，不会让任何同学(线程)掉队

```rust
let barrier = Arc::new(Barrier::new(N_THREADS));
for _ in 0..N_THREADS {
    let barrier_c = barrier.clone();
    handles.push(std::thread::spawn(move || {
        println!("Before wait");
        barrier_c.wait();
        println!("After wait");
    }));
}
```

## ConVar

一般要搭配Mutex一起使用(构成一个二元组)

ConVar不是阻塞全部线程，而是满足指定条件前阻塞一个想要获得Mutex的线程

## Atomic

避免编译器优化语句的执行顺序，导致CPU的寄存器读写内存时出现Data Race

- SeqCst: 排序一致性，先写(store/release)后读(load/acquire)，一致性强，性能最差
- Relaxed: 读写顺序自由，性能最好但是存在Data Race

第三方库crossbeam提供consume原子序，不过仅ARM架构的CPU支持

## 基于消息通信的并发模型

经验之谈:

!> 不要使用共享内存来通信，而是「使用通信实现共享内存」

基于消息通信的并发模型主要有两种: Actor(Erlang), CSP(Golang)

Actor模型的缺点是耦合程度高于CSP，因为CSP不区分发信者和收信者

CSP(通信顺序进程): Communicate sequential process

### MPSC

std::sync::mpsc aka Multi Producer Single Consumer FIFO queue

Rust的mpsc默认是spsc，除非tx进行clone才会变成mpsc

一个生产者和一个消费者的通道叫「流通道(streaming channel)」

多个生产者和一个消费者的通道叫「sharing channel」

共享通道的`for each in rx.iter()`语句会阻塞进程，而且性能比流通道查且析构也比较复杂

不管是mpsc或spsc的通道都是使用链表实现的，增删性能好

MPMS channel请用crossbeam库

## 线程池

[Java线程池实现原理及其在美团业务中的实践](https://tech.meituan.com/2020/04/02/java-pooling-pratice-in-meituan.html)

池化技术的应用: 内存池、数据库连接池、实例对象池、线程池

池化的应用场景都有以下特点: 构造/析构的性能消耗大，对资源无限申请缺乏抑制手段

所以线程池的优点是: 降低资源消耗、提高响应速度、提高线程的可管理性、提供更多更强大的功能(Task延期或定时执行)

利用线程池并行任务的库推荐: rayon

## 并发性能杀手: 伪共享(False Sharing)

在CPU多级缓存系统中，都是以缓存行(Cache Line)为基本单位进行存储的

~~当程序中的数据是段连续内存时，可以被L1缓存一次加载完，如果数据结构是非连续内存，则会出现缓存未命中的情况~~

不同线程操作同一个缓存行的不同字节时，不仅会带来Data Race，而且同时只能有一个线程读写共享数据的缓存行，导致并行的线程变one by one的串行，这就是False Sharing

为了避免线程1和线程2的thread_local变量内存布局分布在同一个CPU缓存行上，造成线程1和线程2不能同时读取同一缓存行的数据带来的伪共享问题，

「就必须将多线程之间的数据隔离到不同的缓存行中」，从而提升并发性能

例如crossbeam库的CachePadded可以进行缓存行填充从而避免伪共享

## SIMD

Single Instruction Multiple Data

例如加法指令，SIMD可以让控制器控制多个CPU，每个CPU并行读一个数再相加

## 并发编程题1: 哲学家进餐问题

[Rust Book猜数字和哲学家进餐问题的项目式教学](https://doc.rust-lang.org/1.0.0/book/dining-philosophers.html) 

## 并发编程题2: 多线程归并排序

[PingCap talent plan 第一周作业](https://docs.google.com/document/d/1UG0OHuL6l_hHWs3oyT9gA2n7LuYUfV23nmz0tRvXq2k/edit#)
