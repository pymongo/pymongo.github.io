
# [重新思考 try/Result](/2023/09/rethink_of_try_catch_and_result.md)

## Result<usize> 的不足

[v2ex 关于 Go/Rust 异常处理的撕逼](https://www.v2ex.com/t/712344)

> rust 的成功，也包含两种成功，一种表示 EOF，一种表示读了一些。rust 的失败，也不止一种失败，而且 Interrupted 是一种特殊的失败，它并不是真的失败，只是暂时的失败

在 Golang 中最后一次 Read() 可能返回 42,io.EOF 但是在 Rust 中需要两次 read() 一次返回 Ok(42) 第二次返回 Ok(0) 我觉得在 read 系统调用次数上应该是一样的，但看上去 Rust 似乎会多一次 std::io::Read::read 的函数调用

## Exception 跨线程问题

重看了 chenhao 极客时间专栏错误处理文章，例如函数 atoi 不会设置 errno 无法/难以得知调用是否成功使用要谨慎

复习下 Python 的 Exception 嵌套

> PEP 上说 raise..from 是显式的连锁(多层嵌套)异常(`__cause__`)，一般的异常是隐式的连锁嵌套(`__context__`)

我更关心 C++/Java/Python 异步编程/多线程中如何实现当前线程 try-catch 其他线程的 Exception

> 在C++、Java和Python中，无法直接在一个线程中捕获另一个线程抛出的异常。需要通过一些通信机制获取异常

Java 可以 Thread.setDefaultUncaughtExceptionHandler
