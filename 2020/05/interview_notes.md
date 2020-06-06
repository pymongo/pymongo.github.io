# [技术面试复习大纲](/2020/05/interview_notes.md)

## 编程范式

### Actor

<i class="fa fa-hashtag"></i>
Q: 什么是Actor System

最早起源于Erlang，是一种类似线程的数据结构。著名的Actor框架有Java的Akka。

无论是Akka、Rust的Actix还是Go的isrs，用Akka实现的Web框架几乎都是性能最好的框架，例如actix-web是Rust性能最好的Web框架。

<i class="fa fa-hashtag"></i>
Q: 比Spring Boot性能更好的框架?

Akka(Actor)

### 异步和同步

<i class="fa fa-hashtag"></i>
Q: 为什么要异步编程

能充分利用CPU的空闲时钟周期，性能更好

<i class="fa fa-hashtag"></i>
await的作用

异步变同步，用同步的思维写异步编程的代码

futures do nothing unless polled or await

### 类型较丰富语言和类型不丰富语言

自从Go/Rust做到了编译语言的自动类型推断以后，而且Rust/Java也有REPL环境，

我认为不能局限于 动态/静态 和 弱类型/强类型 语言这两个维度去看待编程语言

我个人认为更可靠可以分为 类型较丰富语言 和 类型不丰富语言

例如Python

例如Java，有符号的无符号的整数都叫int或long，在python里就只是一个Number

但是在Rust/Go/C/C++中，整数还分u8、u32......

---

## Rust

### Rust答疑

Rust 1.44更新日志中有这么一段：

[Special cased vec![] to map directly to Vec::new(). This allows vec![] to be able to be used in const contexts.](https://github.com/rust-lang/rust/pull/70632)

PR description中有大量的`IR`缩写，请问IR指的是什么？

---

## ByteDance

### 算法题侧重点

1. Easy或Medium难度就够了

2. 树/图这种考的少，数组/dp/双指针/逻辑(智商题)这种可能考的比较多

以下是bytedance某员工对我简历版本(c6c730bdf714fd544af589580ec3e0c25c13f470)的review建议

### 博客和leetcode要不要写

简历里千万不要出现刷题的经历或leetcode项目

个人博客算是亮点，放到联系方式里，后者在自我介绍中加上，不要单独写成一个项目

### 开源项目参与

如果开源项目投入度/参与度不高，只是一些边边角角的PR，可以穿插进项目经历中，或者放在简历最后独立写

---

## 多线程

### Atomic原子序

TODO

### 全局变量和单例模式

### 多线程的单例模式

---

## 内存管理

### 智能指针

在C++11中，会有三种智能指针

- unique_ptr: 独占内存，不共享。在Rust中是: std::boxed::Box
- shared_ptr: 以引用计数的方式共享内存。在Rust中是: std::rc::Rc
- weak_ptr: 不以引用计数的方式共享内存。在Rust中是: std::rc::Weak

---

## C/C++

### 虚函数(实现多态)

TODO

### 虚析构函数

TODO

---

## Java

### 单例模式

懒汉、饿汉、双重校验锁、静态内部类

延迟加载问题、多线程的单例模式问题

TODO

---

## 数据库

### 分库分表

### FOR UPDATE悲观锁

TODO

---

操作系统
比如说：操作系统如何实现“函数调用”（包括：参数传递 ＆ 返回值传递）
比如说：进程的内存布局
比如说：“堆内存”与“栈内存”的差异
比如说：虚拟内存的原理
比如说：各种缓存机制
比如说：并发相关的一些机制
......

编程语言的底层
比如说：当你用的编程语言支持“运行时多态”，你需要知道编译器/解释器是如何做到的。
比如说：当你用的编程语言支持“异常机制”，你需要知道“异常抛出 ＆ 异常捕获”的原理
比如说：当你用的编程语言支持“GC”（垃圾回收），你需要懂 GC 的原理
比如说：当你用的编程语言支持“GP”（泛型编程，比如 C++ 的 template），你需要支持编译器如何实现 GP
......

数据库的底层
（如果你开发的软件涉及数据库，这方面也需要懂一些）
比如说：查询语句的不同学法，性能差异如何（单单这条，就足以写一本书）
比如说：索引的类型及原理（包括：不同类型业务数据，如何影响索引的性能）
比如说：事务的原理，事务如何达到 ACID（很多程序员连事务的 ACID 都没听说过）
比如说：表结构的设计，有啥讲究
......

网络的底层
（如果你开发的软件涉及网络，这方面也需要懂一些）
比如说：OSI 7层模型
比如说：你用到的网络协议的规格
比如说：分布式的软件系统，会碰到哪些【根本性的困难】
比如说：CAP 定理
......

## 其它

### 相比Ruby，Rust的优势是

1. 没有不能编译的第三方库，Ruby的话一言难尽，例如passgen编译失败、某些依赖llvm编译的库也会失败等等
    Rust的很多第三方库的安装不依赖于各种系统包例如libxxx、llvm等等
2. Rust的第三方库不依赖Rustc的版本，不像Ruby的httparty，
    在Ruby2.6.1版本上能发www-form的POST请求，
    在Ruby2.5.0版本发送的www-form的POST请求是错误的(非标准格式)