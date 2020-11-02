# PhantomData

~~主要为了让Unsafe Rust中占位(类似maybe uninit?)错误的类比~~


在标准库中我目前看到三处PhantomData的应用:

1. LinkedList中marker字段的PhantomData可以给链表添加一个「自动Drop」的标记，因为链表内部有NonNull原始指针，加上PhantomData marker的好处是可以自动调用析构方法
2. std::task::Context
3. SyncOnceCell
