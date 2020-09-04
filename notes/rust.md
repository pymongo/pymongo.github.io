# Rust笔记

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

## std::lazy::OnceCell

rust-analyzer作者写的OnceCell已加入Rust的nightly版本中

## RC和ARC的区别

RC是单线程共享内存，ARC是多线程共享，ARC中的A全称是Atomic

## Fn、FnMut、FnOnce的区别

TODO

## ✭生命周期

Rust为了避免多个引用指向相同内存内容带来的数据竞争、数据同步问题

只允许一个内存地址 同时存在一个&mut或同时存在多个&不可变引用

但是如果不用引用计数且多个不可变指针指向同一个内存地址，很可能带来野指针问题

例如某个变量有多个引用，但是变量离开某个作用域后被Drop掉了，但是该变量的外层作用域仍有指向被Drop掉变量的指针

这就有问题了，很可能`use after free`，如果是简单的引用生命周期问题，Rust编译器能检查出来

但是对于一些根据运行时的变化而决定的引用，例如判断两个字符串引用的长度，最后返回较短的

Rust的编译器在编译时就不知道函数最后要返回要返回引用a还是返回引用b，这时候需要程序员通过生命周期标记告诉编译器引用a和b的生命周期是什么

其中一种生命周期是'static 表示引用指向的内存跟程序的生命周期一样长

但是生命周期也不能滥用，如果违反了实际的生命周期，编译器还是会报错

如果是结构体内某字段是一个引用，那么结构体的生命周期<=字段引用的内存变量的生命周期

## Send和Sync Trait

TODO

## Clone和Copy的区别

## 你知道std::marker::Sized是什么吗

Types with a constant size known at compile time

## rust编译过程中LLVM的作用

rustc类似前端，LLVM会将rust编译的结果变成不同target平台的机器码

## PhantomData

TODO

## Rust如何避免内存错误

- deref空指针 -> Option<T>
- 使用未初始化的内存 -> 编译器检查
- 悬垂指针(use after free) -> Ownership+liftime
- 缓冲区溢出(例如数组越界) -> 数组编译时检查越界，vector运行时越界会panic，不会像C/C++那样越界也能继续访问
- 多次free -> 编译器检查

---

## Rust如何实现无GC的内存管理

### ★类似C++的RAII

Resource Acquire Is Initialize

用局部变量管理资源(有限的资源例如内存、套接字)

例如Mutex管理的内存资源，在Rust中.lock()之后无需unlock，MutexGuard离开当前作用域后会「自动析构」

### ★胖指针(Fat Pointer)

Fat Pointer由两部分组成，一部分是指针，另一部分是长度

例如&str就是一个胖指针，同时保存长度信息和堆内存的指针

---

## ★Rust编译原理

中介码 aka IR(Intermediate representation)

LLVM can provide the middle layers of a complete compiler system, taking intermediate representation (IR) code from a compiler and emitting an optimized IR.

This new IR can then be converted and linked into machine-dependent assembly language code for a target platform

rustc将rust源码经过分词和解析生成AST(抽象语法树)，再进一步处理为HIR -> MIR(Middle IR)，最终得到LLVM IR，让LLVM生成各个平台的机器码

miri是一个Rust的MIR解释器

## Rust琐碎知识

### Affine types

type can only move not copy

### 字面量

10为int类型的字面量

### never类型

never类型完善了Rust的类型系统，将一些没有返回值的例如panic情况也纳入了类型系统

例如break/continue也是never类型，保证了if/match语句每个分支的类型都一致

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
