# [sloppy counter](/2023/09/sloppy_counter.md)

OSTEP 介绍了一种多线程安全的高性能计数器叫 sloppy counter, 我一开始疑惑这又有什么用

gpt 的一句话点醒了我 **缺点是近似的计数方法**

我仔细想想，书中说某个处理器核心都独自保存一个计数，当 per cpu core 的计数超过阈值后清零更新到全局的计数器中

这种方法极大降低了多个线程频繁原子操作更新全局计数的开销，但缺点是全局的计数器的数值会有延迟实时性不够

我想到的一种实现方法是通过 __thread 定义 Thread Local Storage 每个线程局部计数器变量

然后通过调整 CPU 亲和性让线程都固定调度在不同 CPU 核心上，这样相当于每个 CPU core 的 L1 cache 都有私有的局部计数器变量

但 OSTEP 书中更聪明，维护一个所有线程ID->counter的映射数组，每次线程想增加计数器时，先从数组找到自己线程的局部计数器去自增，这样就不用改CPU调度的亲和性了

OSTEP ch29 Locked Data Structures

<https://twitter.com/ospopen/status/1700119320091910306>
