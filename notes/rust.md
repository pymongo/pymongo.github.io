# Rust笔记

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

简单来说返回两个字符串中较长字符串的函数就「不能省略生命周期标记」

其中一种生命周期是'static 表示引用指向的内存跟程序的生命周期一样长

但是生命周期也不能滥用，如果违反了实际的生命周期，编译器还是会报错

如果是结构体内某字段是一个引用，那么结构体的生命周期<=字段引用的内存变量的生命周期

标记生命周期并不能改变引用实际的生命周期，只是帮组编译器检查悬垂指针，但是使用了错误的生命周期时依然会报错

### NLL问题

Non-Lexical Lifetimes (NLL): 非词法作用域生命周期

举例子:

```rust
fn main() {
    let mut scores = vec![1, 2, 3];
    let score = &scores[0];
    scores.push(4);
}
```

```
error[E0502]: cannot borrow `scores` as mutable because it is also borrowed as immutable
 --> src/main.rs:4:5
  |
3 |     let score = &scores[0];
  |                  ------ immutable borrow occurs here
4 |     scores.push(4);
  |     ^^^^^^ mutable borrow occurs here
5 | }
  | - immutable borrow ends here
```

代码里的score明明没有用到，为什么不让借用，因为编译器堆score的作用域检查理解的是main函数的score内

现在可以在nightly中使用`#![feature(nll)]`去启用nll

还有一个例子撮合引擎的订单优先队列中，我的&mut orders和orders.peek_mut()两个指针「不能同时出现」，可能我只是改了堆顶订单，没有修改堆，但是编译器不允许

所以现阶段我只能先将堆顶订单弹出后才能操作

再举一个NLL问题的例子:

```rust
let x = "a".to_string();
let z;
let y = "bb".to_string();
z = longer(&x, &y);
```

由于z借用了y，所以z的生命周期必须比出借方y短，但实际上xyz在同一个作用域，原因是Rust借用的检查机制

## Send和Sync Trait

借助这两个Trait实现编译时数据竞争问题的检查

Send/Sync/Copy这三个trait仅仅用于标记，内部代码为空

```rust
pub unsafe auto trait Send {
    // empty.
}
```

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
- double free -> 编译器检查

线程崩溃时会触发提前析构

## Rust解决野指针三大成因

- 指针变量未初始化: 编译器检查
- 指针指向内存释放后未讲置空: Rust的析构会把指针变量也析构了
- deref操作超过变量作用域: 借用检查+生命周期 

而C++尝试move掉unique_ptr智能指针时编译不会报错

---

# 析构函数

由于栈内存的特性，Rust的析构顺序正好跟let语句定义变量的顺序相反

## ✭内存泄露三大原因

- 线程panic，析构函数没法调用
- 使用Rc时不当造成循环引用(例如双向链表中头尾互连)
- 调用mem::forget函数主动泄露

循环引用引起的内存泄露问题还可以使用Arena模式来解决，简单来说就是利用线性数组来模拟节点之间的关系，可以有效避免循环引用

### forget存在的意义

FFI编程与外部函数打交道时，例如FFI编程把值交给C语言处理，Rust要使用forget防止析构被调用

## drop-flag

TODO

## shadowing不会调用析构，不等于生命周期提前结束

## Copy Type没必要存在析构函数

---

## Rust如何实现无GC的内存管理

为了保证GC在工作时不会引入新的"垃圾"，所以运行中的程序要暂停

### 堆内存分配算法

两大类: 空闲链表(Free List)和位图标记(Bitmap)

空闲链表概述: malloc分配堆内存时遍历链表找空闲节点，会将空闲节点删除，当空间回收后再将其加到空闲链表中，缺点是链表如果遭到破坏就无法继续工作

位图标记: 每次malloc都分配连续内存，并将内存标记为1，回收时再标记为0，缺点是内存碎片较多

不管哪种算法都是分配或释放虚拟内存，通知例如FreeBSD平台的jemalloc内存适配器统一整理物理内存

Rust默认使用alloc_system，开发者也可以指定使用jemalloc

### jemalloc

jemalloc的优点有: 分配或回收内存更迅速、内存碎片更少、多核友好、良好的可伸缩性

它将整块批发内存(chunk)以供程序使用，而非频繁的系统调用(brk,mmap)来向操作系统申请内存

其内存管理采用层级架构，分别是线程缓存tcache、分配区arena和系统内存(system memory)

不同大小的内存块对应不同的分配区。每个线程对应一个tcache，tcache负责当前线程所使用内存块的的申请和释放，避免线程间锁的竞争和同步

tcache是对分配区arena中的内存块的缓存，当没有tcache时则使用arena分配内存。

arean则采用内存池思想堆内存区域进行了合理划分和管理，在保证低内存碎片的前提下实现了不同大小内存块的高效管理

当arena中有不能分配的超大内存时，再直接调用mmap从系统内存中申请，并使用红黑树进行管理

我理解是C++/Rust调用malloc函数向 内存分配器jemalloc申请虚拟内存，然后jemalloc再向操作系统进行系统调用申请内存

即便堆内存的分配算法再好，访问性能也不如栈内存，堆内存需要通过栈上的指针去访问，这就多了一层内存访问的跳转，所以能用栈内存就尽量用

### static变量存在哪

既不在堆内存也不在栈内存，而是和程序代码一起存在静态存储区，Rust字符串的字面量也是在静态存储区

### CPU的字长

CPU能在单位时间内(一个时钟周期内?)处理的数据大小称为字长，例如32位CPU字长是32，那么32位CPU的寄存器是不是都是32位呢

### 内存对齐

因为32位CPU要按4字节对齐，所以内存对齐也称为字节对齐

例如有个结构体由u8,u16,u32三个字段组成，为了让32位CPU能在2个单位时间内读取完，需要给u8附近补一个没用的字节去实现内存对齐

### valgrind工具检查堆内存泄露

例如Rust/C++编译生成的二进制文件是a.out，直接用valigrind a.out就能检查

### 浅复制和深复制

按位复制=栈复制=浅复制，而深复制指的是栈上数据和指向的堆数据一起复制

---

## ★Rust编译原理

中介码 aka IR(Intermediate representation)

LLVM can provide the middle layers of a complete compiler system, taking intermediate representation (IR) code from a compiler and emitting an optimized IR.

This new IR can then be converted and linked into machine-dependent assembly language code for a target platform

rustc将rust源码经过分词和解析生成AST(抽象语法树)，再进一步处理为HIR -> MIR(Middle IR)，最终得到LLVM IR，让LLVM生成各个平台的机器码

miri是一个Rust的MIR解释器

Rust源码编译生成的二进制文件在build/x86_64-unknown-linux-gnu/stage2/bin内

迭代器的Fuse适配器: 遇到一个None就提前结束

### 自制编译器插件

[rust compiler plugin](https://doc.rust-lang.org/1.5.0/book/compiler-plugins.html)

## Rust琐碎知识

### Affine types

type can only move not copy

### 字面量

10为int类型的字面量

### never类型

never类型完善了Rust的类型系统，将一些没有返回值的例如panic情况也纳入了类型系统

例如break/continue也是never类型，保证了if/match语句每个分支的类型都一致

### Union类型

跟C/C++的union一样，所有字段都共享一段内存，但是Rust的Union用起来需要各种unsafe

union类型在Rust中的应用: std::mem::ManuallyDrop

ManuallyDrop是一个联合体，所有字段共享内存，不能随便被析构，所以Rust不会自动为联合体实现析构函数

我们可以通过ManuallyDrop自定义析构顺序，mem::forgot()内部就是通过ManuallyDrop去实现

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

### 缺点.trait的孤儿规则和不可重叠规则

### 缺点.过于复杂的生命周期嵌套+组合

### Go的缺点

Go很难去做performance critical的应用场景，主要有两个原因

一、GC机制

tikv底层用的是LSM tree数据结构，不是一个「GC友好的pattern/数据结构」

这种数据结构在内存中有个类似LRU小对象的缓存池，小对象会经常换入换出使得GC的压力很大

二、Go屏蔽了system thread，封装成goroutinue

Go把操作系统线程相关的API都抹掉了，中间加了一个Go调度器实现系统线程和Go协程的调度

Go协程开的多时，协程上下文切换带来的开销比操作系统线程切换要大，而且Go的CPU平均负载要比C++高20%

### PingCap为什么不用C++14

CTO维护大型C++项目例如前端hybrid时用到了chrome源码，内存管理坑，可以让自己团队高要求避免内存泄露，但是也防不住第三方库是猪队友，第三方库智能指针传染等问题

缺乏包管理和生态

### Rust适合应用的场景

非得用Rust不可的场景: 存储层(榨干操作系统的性能)、操作系统内核/驱动、浏览器内核
