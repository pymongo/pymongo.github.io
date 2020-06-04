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

## 数据库

### FOR UPDATE悲观锁

TODO
