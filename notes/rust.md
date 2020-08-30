# Rust笔记

## 等待答疑

Rust 1.44更新日志中有这么一段：

[Special cased vec![] to map directly to Vec::new(). This allows vec![] to be able to be used in const contexts.](https://github.com/rust-lang/rust/pull/70632)

PR description中有大量的`IR`缩写，请问IR指的是什么？

## 智能指针

如果程序员忘记在调用完temp_ptr之后删除temp_ptr，那么会造成一个悬挂指针(dangling pointer)

迷途指针/悬空指针/野指针指的是指针指向的对象free之后，没有回收指针变量的现象，容易造成used after free

scoped_ptr: 所指向的对象在作用域之外会自动得到析构，intrusive_ptr实际工作中用不到...

不要拿C++11的智能指针去类比Rust的智能指针

要记住Rust的智能指针远远不只不只三种，这种类比是不准确的

具体看[Rust Memory Container Cheat-sheet](https://github.com/usagi/rust-memory-container-cs)

### Cell和RefCell

共同点: 让结构体的某个字段mut，形象比喻是给结构体打一个孔，让某一部分变得mutable

但Cell和RefCell除了可以让结构体部分可变，也可以让结构体整体可变，要灵活使用

不同点: Cell<T>建议用于Copy-Type

解释:

Cell provides you values, RefCell with references(所以内存体积较大的结构体类型还是用RefCell)

Cell never panics, RefCell can panic

知识扩展: OnceCell建议用于non-Copy-Type

在C++11中，会有三种智能指针

- unique_ptr: 独占内存，不共享。在Rust中是: std::boxed::Box
- shared_ptr: 以引用计数的方式共享内存。在Rust中是: std::rc::Rc
- weak_ptr: 不以引用计数的方式共享内存。在Rust中是: std::rc::Weak

### 单线程独占内存

C++是unique_ptr TODO 为何摒弃了auto_ptr(因为unique_ptr更优，为什么更优?) 

Rust独占堆内存不共享: Box

注意: RefCell、Cell、Box只能用于单线程

例如Rust的链表节点的next字段的类型是 Option<Box<ListNode<T>>>

### 单线程共享内存

C++ shared_ptr(实际上是引用计数)、weak_ptr(不以引用计数的方式共享内存)

Rust与之对应的是Rc和Weak

例如Rust二叉树节点中的left字段类型是 Option<Rc<RefCell<TreeNode>>>

需要注意的是Rc和Box不能同时使用

### 多线程独占内存

Mutex/RwLock

### 多线程共享内存

一般用Atomic或ARC套Mutex/RwLock/Atomic

## RC和ARC的区别

RC是单线程共享内存，ARC是多线程共享，ARC中的A全称是Atomic

## Rust如何实现多态？

TODO

## trait和generic的关系和区别

The Rust Programming有一章专门将trait和generic的关系

## Fn、FnMut、FnOnce的区别

## Send和Sync Trait

TODO

## Clone和Copy的区别

## 你知道std::marker::Sized是什么吗

Types with a constant size known at compile time

## rust编译过程中LLVM的作用

rustc类似前端，LLVM会将rust编译的结果变成不同target平台的机器码

## PhantomData

TODO

---

## Rust一些优点

- 部署简单
- derive过程宏相比反射机制性能更好
- 没有不能编译的第三方库，Ruby的话一言难尽，例如passgen编译失败、某些依赖llvm编译的库也会失败等等

- Rust的第三方库不依赖Rustc的版本，不像Ruby的httparty，
  在Ruby2.6.1版本上能发www-form的POST请求，
  在Ruby2.5.0版本发送的www-form的POST请求是错误的(非标准格式)

### 脚本语言的一些劣势

服务器过载情况下 latency 和超时率，脚本类语言在负载范围的时候感觉不出来

一旦服务器过载性能急剧下降，或者抖动特别厉害

## Rust的缺点

### 缺点.异步生态不统一

tokio和async_std之争，不支持async triat但Actor里所有通信操作都是异步的需要在同步的函数里写异步的代码块

tokio和actix_rt异步运行时

### 缺点.不能处理内存分配失败的情况(C语言可以)

### 缺点.不支持const generic

### 缺点.过度依赖宏

宏带来可读性差、静态检查等问题，现阶段IDE不支持宏的语法高亮等

---

## Trait

### Ord & PartialOrd

这两个 Traits 的名称实际上来自于抽象代数中的「等价关系」和「局部等价关系」

二者的都实现了

- 对称性(Symmetry): a==b可推出b==a
- 传递性(Transitivity): a==b,b==c可推出a==c

Eq多实现了反身性(Reflexivity): a==a

为什么PartialOrd的返回值是Option<T>? 是为了考虑lhs是None的情况

---

## 编译器相关

### inline函数

FFI编程相关，C语言宏在 Rust 中会实现为 #[inline] 函数

## Cargo相关

#### cargo tree解决第三方库版本问题

```
root@remote-server:~/app# cargo tree -d | grep md-5
└── md-5 v0.9.0
└── md-5 v0.9.0 (*)
```

#### cargo expand(宏展开)

推荐在一个子文件夹内(就一个lib.rs)使用cargo expand，否则将项目的所有rust源文件都展开的话，输出结果长得没法看完

#### cargo alias

在项目根目录新建一个文件 .cargo/config 就能实现类似npm run scripts的效果

IDEA运行同一个文件的多个单元测试函数时，默认是多线程的，建议加上--test-threads=1参数避免单元测试之间的数据竞争

```
[alias]
myt = "test -- --test-threads=1 --show-output --color always"
matcher_helper_test = "test --test matcher_helper_test -- --test-threads=1 --show-output --color always"
run_production = "cargo run --release"
```

#### 单线程运行单元测试

`cargo test --test filename function_name -- --test-threads=1 --show-output`

