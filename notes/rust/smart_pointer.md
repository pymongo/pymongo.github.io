# Rust智能指针

如果程序员忘记在调用完temp_ptr之后删除temp_ptr，那么会造成一个悬挂指针(dangling pointer)

迷途指针/悬空指针/野指针指的是指针指向的对象free之后，没有回收指针变量的现象，容易造成used after free

scoped_ptr: 所指向的对象在作用域之外会自动得到析构，intrusive_ptr实际工作中用不到...

不要拿C++11的智能指针去类比Rust的智能指针，要记住Rust的智能指针远远不只不只三种，这种类比是不准确的

而且Vec和String也是智能指针

部分智能指针脑图可以看[Rust Memory Container Cheat-sheet](https://github.com/usagi/rust-memory-container-cs)

## ★RAII机制

RAII = Resource Acquire Is Initialize, 源于C++

用局部变量管理资源(有限的资源例如内存、套接字)

例如Mutex管理的内存资源，在Rust中.lock()之后无需unlock，MutexGuard离开当前作用域后会「自动析构」

## 自引用类型和Pin

所谓自引用类型就是一个结构体内有指向自身的指针

### Pin/UnPin/!Unpin的区别

## ★胖指针(Fat Pointer)

Fat Pointer由两部分组成，一部分是指针，另一部分是长度

例如&str就是一个胖指针，同时保存长度信息和堆内存的指针

胖指针指向的内容可以是在静态存储区或堆内存

## NonNull指针

Rust官方建议用于*mut T原始指针的安全的替代品，一定非空而且遵循生命周期的协变规则

## 染色指针和64位寻址

64位计算基本还是有用，但是64位寻址是否有必要真的存疑，很多实际场景和benchmark表明，指针宽度扩大一倍对lcache绝对不是好事

所以

64位操作系统的指针大小都是8 bytes，实际上4bytes可以索引4G内存，5-6bytes都足够用了(指针用48bit寻址够用了)，所以可以让将少量额外的信息存储在指针上

业界通用的做法是64bit中取16bit来存储额外信息，提供内存利用率

例如Rust的tagged enum(编译器打洞)，size of enum

可以让enum的tag塞到染色指针存储信息的16bit中

## 指针的大小一定是usize吗？

在冯诺依曼架构的CPU上一定是，在哈佛架构的CPU上不一定，例如gcc-avr

哈佛架构的instruction_memory和data_memory的位宽可能不一样

### String和Vec<u8>的区别

String是一段合法的UTF-8编码的u8序列，可以安全地转为一段合法的字符串

但反过来Vec<u8>就不能安全地保障或转换为字符串

## Cell和RefCell

共同点: 让结构体的某个字段mut，形象比喻是给结构体打一个孔，让某一部分变得mutable

但Cell和RefCell除了可以让结构体部分可变，也可以让结构体整体可变，要灵活使用

不同点: 

1. Cell建议用于Copy-Type
2. Cell使用set/get直接操作值，RefCell通过返回borrow/borrow_mut包装过的引用来操作值
3. Cell没有运行时开销，而RefCell运行时在维护一个额外的借用检查器，带来额外开销
4. let mut handle = ref_cell.borrow_mut();编译时不会报错，运行时会panic: double mut borrow


解释:

Cell provides you values, RefCell with references(所以内存体积较大的结构体类型还是用RefCell)

Cell never panics, RefCell can panic

知识扩展: OnceCell建议用于non-Copy-Type

!> 我很赞同这个观点: RefCell is lie to the compiler

滥用RefCell/OnceCell会觉得自己的代码lie to compiler

## 单线程独占内存

C++是unique_ptr TODO 为何摒弃了auto_ptr(因为unique_ptr更优，为什么更优?) 

Rust独占堆内存不共享: Box

注意: RefCell、Cell、Box只能用于单线程

例如Rust的链表节点的next字段的类型是 Option<Box<ListNode<T>>>

## 单线程共享内存

C++ shared_ptr(实际上是引用计数)、weak_ptr(不以引用计数的方式共享内存)

Rust与之对应的是Rc和Weak

例如Rust二叉树节点中的left字段类型是 Option<Rc<RefCell<TreeNode>>>

需要注意的是Rc和Box不能同时使用

## 多线程独占内存

thread_local!

## 多线程共享内存(ARC)

一般用`Atomic<T: Copy>` 或 `Arc<Mutex/RwLock/Atomic>` 或 `SyncOnceCell<Mutex/RwLock/Atomic>`

或者用 crossbeam::scope(以前在标准库，后来因内存泄漏被删)，scope可以保证子线程比父线程活短避免父线程变量传入子线程而父线程先析构从而悬垂指针

但是有人说ARC是一条错误道路，还不如GC:

1. Arc容易循环引用
2. 额外的运行时开销: extra overhead，在一些performance critical场景影响大

对于无状态的服务/server，完全可以等内存/CPU负载到一定程度自动重启，有可能性能更好，因为(C++)delete操作还是比较慢的

再配上容器，杀掉旧的负载高server进程前，把新的容器启动起来，新的启动起来，旧的下线

### AtomicPtr建议使用Copy类型

Atomic相当于线程安全版的Cell

单线程Cell: RefCellOnceCell

## 相似智能指针之间的区别

### 大Box和小box的区别

目前「box关键字」是实验性功能，仅在Rust源码中能使用，例如Arc/Rc/Box源码里就用到了box

### RC和ARC的区别

RC是单线程共享内存，ARC是多线程共享，ARC中的A全称是Atomic

---

## 其它智能指针

### std::lazy::OnceCell

rust-analyzer作者写的OnceCell已加入Rust的nightly版本中

### Cow(Copy on Write)

Copy on Write(写时复制技术)是一种优化策略，我的理解是Copy的升级版，只有当Copy后会修改值才会复制一份

例如Linux中父进程创建子进程时，并不是让子进程立刻复制一份进程空间，而是先让子进程共用父进程的进程空间

只有等到子进程需要写入时才会复制进程空间，这种lazy的策略减少了系统的开销

Rust的Cow全称是Clone On Write

> provide immutable access to borrowed data, and clone the data lazily when mutation or ownership is required

Cow的应用: 跨线程地统一&str和String
