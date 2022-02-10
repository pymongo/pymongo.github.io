# [BinaryHeap Hole](2022/02/binary_heap_hole.md)

之前看 BinaryHeap 源码的时候很困惑为什么 sift_up 操作需要造一个 Hole 数据结构

后来看死灵书第七章 unwinding 的时候就解释了，其实「就是为了减少一次拷贝」

例如有些数组内扩容或者交换的操作，如果用 Java 写可以很简单避免数组越界

> try temp=arr[i], catch IndexOutOfRange arr[i]=temp

也就是当操作发生异常时能恢复成 sift_up 之前的状态

死灵书说 Rust 的 catch panic 或 unwind 性能开销甚至比 Java 还大

所以造了一个 Hole 的数据结构减少拷贝(操作前 temp=arr 存储之前状态)
并达到类似 try-catch 效果能在越界后恢复之前状态
