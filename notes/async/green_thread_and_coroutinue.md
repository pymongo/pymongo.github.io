# [为什么异步要用轻量级线程](/notes/async/green_thread_and_coroutine.md)

## system call fork child process

最早Apache服务器用的是pre-fork，每个请求都会创建一个子进程去处理，后来改为worker模式的线程池

master-worker模式(例如puma)需要创建子进程去占满CPU资源(我个人认为要慎用性能毒瘤，puma负载太高了)

有些语言的多线程并不安全，所以就用多进程了

Rust标准库没有提供fork系统调用去创建子进程，因为不需要，子进程会把主进程数据状态都复制一遍，效率太低

现在的软件/server用子进程的并不多，在2021年+，仍然用到多个子进程的应用例子是chrome浏览器

可以用htop命令查看每个进程开辟的线程数

## 为什么要异步

避免naive thread的blocking IO代码使得CPU很多时间片都在空转，NOP空指令，async non-blocking IO能更好的利用时间

## naive/kernel/os thread

操作系统提供的原生线程API，遵循POSIX标准，通常也就(1:1模式)，1个编程语言的线程对应一个naive thread

原生线程的缺点:

1. 一个进程内能创建的线程数有限(不能解决10万并发请求问题: C10K problem)，协程的需求来源于C10K问题
2. 进程内线程之间的切换由操作系统调度(系统调用?)，上下文切换(保存当前时间片老线程状态，以及恢复新线程之前的状态)开销大

## green thread, coroutine

更常见的叫法是"轻量级线程"或worker thread，不太常见的叫法: 纤程(Fiber)

相比于naive thread的(1:1对应)，green thread模型(有栈协程)做到了(N:M对应)，既N个green threads运行在M个kernel threads中

programming language or it's runtime provide you a task abstraction and map numbers of own tasks to os threads

现代化的编程语言例如: Go, Kotlin, Erlang等一般自带协程，Rust协程的优势是可以用thread_local等方法共享协程数据，绕开多线程的数据竞争检查

Go的协程就是通过work stealing算法进行调度

### Rust标准库为什么移除了green thread API

Go没有Native thread的概念，语言层面只支持协程，Rust是系统编程语言，没有VM也没有runtime(it cannot have a significant runtime system)，Rust必须支持naive thread

具体原因去看`RFC 0230-remove-runtime`，为了将green thread和naive thread用同样的trait去抽象，使得green thread引入额外的overhead，不再lightweight

### 有栈协程的缺点:

1. Overhead when calling C(switch between green thread stack and naive stack)
2. Stack growth can cause issue

对于问题1，Go的系统调用其实是被协程调度器包装过的，cgo的执行也是类似的过程。

因为调用的C代码非常有可能通过C库来执行系统调用，这样会使线程进入阻塞，从而影响Go的调度器的行为。

所以我们看到cgo总会执行entersyscall和exitsyscall，就是这个原因。

## (无栈协程)Rust是如何解决协程的上述两个问题

协程的实现可以分为有栈(比较耗内存)和无栈(状态机)两种，Rust的协程可以做到在编译时得知Task需要分配的内存是多大不需要动态分配内存

Rust选择了性能更好的状态机协程实现(具体对比看[刀哥Rust笔记2](https://rustcc.cn/article?id=7b8582fd-bc83-4f5c-81d7-d8ea72d44dda)和[刀哥Rust笔记3](https://rustcc.cn/article?id=c0c47719-be7f-4298-ab5a-507cb65f9538))

无栈协程有很多好处，首先不用分配栈，意味着可以拥有无数个协程，因为究竟给协程分配多大的栈是个大问题。这就是Rust解决有栈协程的问题1

无栈协程没有协程间上下文切换的overhead，不依赖与CPU相关

无栈协程的实现是Generator(生成器)生成的状态机。和Generator状态机有关的语法糖是yield

### Generator模拟Future

相比迭代器，生成器是一种延迟计算或惰性计算

不过生成器也类似迭代器，也适用于序列化几千万条MySQL记录去处理或迭代一个很大的排列组合，每次只在内存中存一条，避免了内存中放不下的问题

如果将生成器返回Yielded看做Pending，Complete表示Ready，不断轮询生成器，则可以得到类似Future的效果

但是生成器能力较弱，只能在调用者和自身间转移CPU使用权，不能实现Future套娃使用

在Future的线程池消息轮询队列中，如果发现当前任务是Pending状态，则重新将该任务发送到Channel中等待下一次轮询

### 无栈协程的缺点

1. 代码、生成器、状态机、异步原理等变得更复杂难懂，学习曲线陡峭
2. 著名的Pin问题(为了异步编程特意引入的Pin)

### Future chain带来的问题

编译时无法检查lifetime

---

## async IO

### sync non-blocking code

sync blocking IO可能大学教科书里较多，现实工程中，Go/Ruby语言看似一行行逐行运行的代码，实际上inside the runtime运行时会转换为non-blocking IO

### epoll

操作系统提供的I/O复用操作，也就是 epoll/IOCP 多路复用加线程池技术来实现的。本质上这类程序会维护一个复杂的状态机，采用异步的方式编码，消息机制或者是回调函数

### async evented non-blocking IO

nginx, Node.js， 在await没出现时，js的异步写法容易陷入回调函数地狱<http://callbackhell.com>

后来回调地狱改成了ES6的promise语法，不停的.then，但是不会像回调那样多层嵌套
