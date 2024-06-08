# [Bytes和Vec<u8>唯一不同](/2024/06/tokio_bytes.md)

为了收到错误的业务状态码响应的时候打印下请求的body，但.body()方法会move掉String

为了减少一次clone，引发我对reqwest body(Bytes)源码阅读

由于只有static的引用才能在async rust中共享，不得不都把引用包层Arc这样有所有权可以move进异步闭包

我注意到reqwest body可以传入Bytes 克隆一次Bytes后面请求后就能打印请求body的Bytes了

此外gpt说Bytes还有一个不同就是不会像Vec push/pop发生内存变化，但不可变的`Vec<u8>`从栈上变量push到另一个二维数组上应该也没事

我之前写过相关的文章 [Vec 动态扩容悬垂裸指针](/2023/08/vec_push_mem_addr_change_cause_ffi_fail.md)
