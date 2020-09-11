# 并发编程

Data Race的主要原因是CPU当前时间片执行哪一个线程是不确定的(乱序执行)，所以不同线程对同一块内存进行读写不能保证数据的线程安全

通常可以使用锁(Mutex,RwLock,Spin)、信号量(Semaphores)、屏障(Barrier)和条件变量(Condition Variable)来保证线程同步

自旋锁和互斥锁类似，但是获取失败时会不断轮询而不是让线程休眠

## Semaphores

对资源访问进行计数，有线程访问是信号量-1，如果信号量等于0，则其它线程想访问是只能等待，当线程访问结束后信号量+1

如果信号量只允许是0或1时，效果相当于Mutex

## 并发编程题1: 哲学家进餐问题

[Rust Book猜数字和哲学家进餐问题的项目式教学](https://doc.rust-lang.org/1.0.0/book/dining-philosophers.html) 

## 并发编程题2: 多线程归并排序

[PingCap talent plan 第一周作业](https://docs.google.com/document/d/1UG0OHuL6l_hHWs3oyT9gA2n7LuYUfV23nmz0tRvXq2k/edit#)
