- [Rust编程之道读书笔记1: 泛型多态](/notes/trait_and_generic.md)

# trait dispatch

## Rust如何实现多态?trait和泛型和多态概述

多态指的是同一种行为，在不同上下文会相应不同的行为实现

泛型可以认为是「参数化多态/(staic多态)」，所以泛型属于动态的一种

根据多态的编译时分发(static dispatch)和运行时分发(dynamic dispatch)可以将Rust三种多态实现按这么分类

## static dispatch

### generic trait bound

泛型在编译时通过单态化分别生成具体类型的实例

而参数化多态依赖于trait去实现，trait简单来说是对类型行为的抽象，trait可以为泛型添加约束条件和行为，也就是trait bound

如果一个泛型就一个光秃秃的T，没有任何trait bound，那它也不算泛型了，因为「啥也干不了」

### impl Trait

举例: impl Future, actix-web的impl Responder

例如actix想要有不同类型的HTTP Response，可以通过Box<dyn Trait>或impl Responder实现

但是impl Trait目前不支持「turbofish语法」(例如query::<u32>)，不如泛型

## dogmatic dispatch

### &dyn Trait/Box<dyn Trait>

Rust没有继承的概念，Rust实现动态分发多态的过程跟Java的向上塑型(upcast)不太一样

多态本身也是泛型的一种实现，Rust通过dyn关键字去定义一个实现了某个trait的类型，例如函数的入参里可以通过dyn Animal表示该参数必须实现了Animal Trait

这提现了Rust 组合(mixin)优于继承、面向接口编程的编程思想

## 静态分发和动态分发的优缺点

静态分发: (优点)zero cost abstract，(缺点)二进制文件体积变大

动态分发: (优点)函数的返回值可以是不同类型(好像静态分发的impl Trait写法也能实现?)，(缺点)运行时查虚表带来性能开销而且需要额外的内存去存储虚表，还有一个缺点是不能自动类型推断

## Trait Object

Rust的类型可以看作是语言允许的最小集合，而trait bound可以对这些类型进行「组合」，也就是求交集

所以也可以认为trait也是一种类型，是一种方法的集合，或者说一种行为的集合

但是trait类型的大小在运行时不可知/无法确定，所以动态分发时要么Box<trait>，要么就&dyn trait

traitObject包含两个指针: data指针和vtable指针，vtable包含了析构函数、大小、对齐和方法等信息

当trait作为traitObject去使用时，其内部类型就默认是Unsize(?Sized)类型，也就是动态类型大小，只是将其置于编译时可确定大小的胖指针的背后，以供运行时动态调用

所以给traitObject加上Sized后，就会陷入薛定谔的类型: 既能确定大小又不能确定大小

!> 要想实现(dynamic?)多态就必须用「对象安全」的trait object

或者说trait Object必须是对象安全的

### trait对象安全的要求

Understanding Traits and Object Safety

1. trait本身没有bound Sized
2. 所有方法的返回值不是Self
3. 所有方法中不包含泛型参数

解释第1点要求: trait对象是一个胖指针，是类似&str那样动态类型大小的，不能约束为Sized

解释第2点要求: trait对象类似Java向上塑型忘记了Self是什么，所以不能在trait对象的任何方法里返回Self

解释第3点要求: 由于trait对象忘记了类型信息，所以无法确认方法中泛型类型究竟是什么

所以`Box<dyn Clone>`会报错因为Clone trait不是对象安全的，因此不能作为trait object

以上3点要求来源于《Rust权威指南》

但是在《Rust编程之道》中对要求2又有不同的定义

2.1 第一个参数必须是self类型或可以解引用为self类型，例如self, &self, &mut self, self: Box<self>(TODO 待勘误)

也就是第一个参数必须是"实例对象的this指针"?

2.2 Self不能出现在除了第一个参数位置以外的地方，包括返回值

---

# trait系统的不足

## trait的孤儿规则

孤儿规则(Orphan Rule): 如果要impl某个trait，则该trait和要实现该trait的类型「至少有一个」要在当前crate中定义

例如Add和u32都在std里定义，如果没有孤儿规则的限制，std库u32的Add的实现就会被篡改产生难以意料的Bug

缺点: 上游库在设计trait时还要考虑要不要实现一个生命周期版本之类的，如果下游的调用者不满意，需要自己重新包装成本地类型才能做修改

特例: 有#\[fundamental]标记都无视孤儿规则

在Rust 1.46.0版本中，无视孤儿规则分别是:

- Sized
- Box
- Pin(固定指针，直到UnPin前指向的内存内容都不会被moved)
- Generator
- Fn/FnMut/FnOnce

## 不可重叠规则

例如`impl<T: Copy> A for T`和`impl<T: i32> A for T`不能同时出现

因为Copy包含了i32，不可重叠规则和孤儿规则一样，为了保证trait的一致性，避免发生混乱

但是重叠规则带来了两个问题:

- 代码难以复用
- 性能问题

### 不可重叠规则的性能问题

```rust
// 例如为所有类型重载 += 运算符
impl <RHS, T: Add<RHS> + Clone> AddAssign<RHS> for T {
    fn add_assign(&mut self, rhs: RHS) {
        *self = self.clone() + rhs;
    }
}
```

上面这段代码中，并不是所有类型都需要性能开销大的clone，因为受到不可重叠规则的限制，不能为一些类型单独去实现(例如上面T: i32和T: Copy的例子)

所以在标准库中，为了更好的性能，只好每种类型单独实现一次(通过宏简化代码)；不能让所有类型实现后，挑出几个「特例」去单独实现

在nightly版本中，推出`specialization (RFC 1210)`去缓解这种现象

特化功能有点像OOP的继承中，通过override重写父类方法，也就是我Copy已经实现了一套A trait，但是我i32可以「override」掉

## Rust缺陷: 迭代器只能按值迭代

例如迭代器读std::io::Lines时只能每次读一行分配到String中，不能重用内部缓冲区，通过引用来复原原始数据

这个问题可以在RFC中搜索: Generic Associated Type，很可惜nightly中也没能实现出来

---

# trait琐碎知识

## Fn/FnMut/FnOnce

当前版本Rust的闭包实现: 通过Fn/FnMut/FnOnce三个trait将「函数调用」变为「可重载的操作符」

(trait所谓的实例方法x.func等于Trait::func(&x))

例如func(x)变成

- Fn::call(&func, (x,))
- FnMut::call_mut(&mut func, (x,))
- FnOnce::call_once(func, (x,)) // 因为take了ownership所以只能调用一次?

如何才能知道自己写出来的闭包被编译器默认实现了哪个Trait?

- Fn: 闭包以borrow的方式捕获外部作用域的变量，同时表示该闭包没有改变环境的能力，并且可以调用多次，对应&self
- FnMut: 闭包以borrow_mut的方式捕获外部作用域的变量，并且可以调用多次，对应 &mut self
- FnOnce: 闭包以move的方式捕获外部作用域的遍历(闭包的move关键字?)，因为该闭包会消耗自身，所以只能调用一次，对应self

!> 闭包会根据需要捕获的外部作用域的类型(例如Copy Type)来决定实现哪个Trait

如果闭包捕获的变量是Copy Type，那么即便调用了FnOnce之后，也能再次调用该闭包

1. 如果闭包没有捕获变量，则默认实现Fn

2. 如果闭包捕获了move语义的变量

2.1 如果不需要修改变量，无论是否使用move关键字均会自动实现Fn

2.2 如果需要修改变量，则自动实现FnMut

3. 如果闭包捕获了Copy语义的变量

3.1.1 如果不需要修改变量，没有使用move关键字，则自动实现FnOnce

3.1.2 如果不需要修改变量，但是使用move关键字，则自动实现FnOnce

3.2 如果需要修改变量，则自动实现Fn

"逃逸闭包"指的是函数返回值返回的闭包函数，带着它捕获到的变量逃离了栈帧，也就是利用闭包实现类似全局变量去保存状态，闭包保存状态

例如`fn outer{ let i=0; return fn inner{}; }` 

所以move的关键字的作用是强制编译器让闭包执行某个确定的捕获变量的方式

### std::boxed::FnBox

想将FnOnce的闭包函数Box<self>移出来调用因为编译时无法确定大小所以无法获取到self，解决方案是FnBox或impl Trait

FnBox貌似在1.46版本已被弃用

### 高阶生命周期for<>

闭包的高阶生命周期: Higher-ranked lifetime，也叫higher-ranked trait bound

解决例如逃逸闭包带走的是变量的指针这种情况

### std::thread::spawn的参数要求FnOnce

## Haskell typeclass

trait借鉴了很多Haskell的typeclass的概念，可以静态生成，也可以动态调用

## Ord & PartialOrd

这两个 Traits 的名称实际上来自于抽象代数中的「等价关系」和「局部等价关系」

二者的都实现了

- 对称性(Symmetry): a==b可推出b==a
- 传递性(Transitivity): a==b,b==c可推出a==c

Eq多实现了反身性(Reflexivity): a==a

为什么PartialOrd的返回值是Option<T>? 是为了考虑lhs是None的情况

## Copy, Clone

实现Copy的同时必须实现Clone，实现Clone的同时必须实现Sized

所以像String实现了Clone又不一定需要实现Copy

## 内部为空的trait

use std::marker::{Copy, Send, Sync, Sized, Unpin, PhantomData(用于Unsafe领域的型变特性)};

Rust标准库的所有类型几乎都实现了Unpin

## IntoIter/Iter/IterMut

区别 self/&self/&mut self，例如for num in nums会将vec的所有权move给IntoIter

Map可以认为是Adapter设计模式

---

# generic

## const generic

Rust暂不支持，所以数组不支持impl <T, const N> for \[T; N]

如果支持的话操作定长度的数组的体验会有极大的提升 

## readelf工具查看二进制文件中泛型/多态的符号

apt/brew install binutils

注意readelf貌似只能在Linux系统下才能正常使用，mac会读不到二进制文件的信息

除了二进制文件，readelf还能查看.so文件的信息

---

杂谈: 学习方法

例如像操作系统、网络编程这样晦涩难懂的知识那只能靠我双拼超快的打字抄一遍，所以网上有个仓库叫Rust抄书之道
