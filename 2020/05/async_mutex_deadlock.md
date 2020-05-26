# [异步时死锁的解决办法](/2020/05/async_mutex_deadlock.md)

用了actix+sqlx两个异步框架后，项目里所有函数被迫写成异步函数了，

结果暴露多线程Mutex变量锁出死锁的问题

我打了大量log调试程式后发现了异步函数的执行顺序

1. 线程1第一次调用函数A
2. 函数A开头要锁住变量X
3. 线程1没等第一次调用函数A走完再次调用A
4. 第二次调用A函数时同步等待变量X的锁被释放
5. 死锁

问题出现的原因：异步环境下使用了同步的Mutex锁

解决方案：将std::sync::Mutex换成async_std::sync::Mutex或tokio的Mutex

如果没有用到RwLock，其实用rust官方维护的futures库内的Mutex锁也是可以的

考虑到actix只支持tokio异步runtime，为了统一异步runtime，用了actix+sqlx技术栈时用tokio的Mutex更好

---

打log的心得：

每个线程可能会blocking的方法调用前打一行log，可以追溯线程为什么会被卡死了
