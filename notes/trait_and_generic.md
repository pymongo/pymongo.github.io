# trait dispatch

## Rust如何实现多态?trait和泛型和多态概述

多态指的是同一种行为，在不同上下文会相应不同的行为实现

泛型可以认为是「参数化多态/(staic多态)」，所以泛型属于动态的一种

根据多态的编译时分发(static dispatch)和运行时分发(dynamic dispatch)可以将Rust三种多态实现按这么分类

## static dispatch

### generic trait bound

而参数化多态依赖于trait去实现，trait简单来说是对类型行为的抽象，trait可以为泛型添加约束条件和行为，也就是trait bound

如果一个泛型就一个光秃秃的T，没有任何trait bound，那它也不算泛型了，因为「啥也干不了」

### impl Trait

举例: impl Future, actix-web的impl Responder

例如actix想要有不同类型的HTTP Response，可以通过Box<dyn Trait>或impl Responder实现

简单来说trait是对类型行为的抽象

## dogmatic dispatch

### &dyn Trait/Box<dyn Trait>

Rust没有继承的概念，Rust实现多态的过程跟Java的向上塑型(upcast)不太一样

多态本身也是泛型的一种实现，Rust通过dyn关键字去定义一个实现了某个trait的类型，例如函数的入参里可以通过dyn Animal表示该参数必须实现了Animal Trait

除了dyn，也可以通过泛型T: Animal去实现多态

这提现了Rust 组合(mixin)优于继承、面向接口编程的编程思想

(当然dyn的缺点也有，运行时查表带来额外的性能开销，例如额外的存储空间，而且let语句也不能自动推断类型)

## 静态分发和动态分发的优缺点

静态分发: (优点)零额外开销的抽象，(缺点)二进制文件体积变大

动态分发: (优点)?，(缺点)运行时查虚表带来性能开销而且需要额外的内存去存储虚表

---

# trait琐碎知识

## Trait Object

Rust的类型可以看作是语言允许的最小集合，而trait bound可以对这些类型进行「组合」，也就是求交集

所以也可以认为trait也是一种类型，是一种方法的集合，或者说一种行为的集合

但是trait类型的大小在运行时不可知/无法确定，所以动态分发时要么Box<trait>，要么就&dyn trait

traitObject包含两个指针: data指针和vtable指针，vtable包含了析构函数、大小、对齐和方法等信息

当trait作为traitObject去使用时，其内部类型就默认是Unsize(?Sized)类型，也就是动态类型大小

只是将其置于编译时可确定大小的胖指针的背后，以供运行时动态调用

所以给traitObject加上Sized后，就会陷入薛定谔的类型: 既能确定大小又不能确定大小

所以多态分发时不要去加上Sized的约束

## trait的孤儿规则

孤儿规则(Orphan Rule): 如果要impl某个trait，则该trait和要实现该trait的类型「至少有一个」要在当前crate中定义

例如Add和u32都在std里定义，如果没有孤儿规则的限制，std库u32的Add的实现就会被篡改产生难以意料的Bug

### trait对象安全

1. 方法受到Self: Sized约束
2. 

## Haskell typeclass

trait借鉴了很多Haskell的typeclass的概念，可以静态生成，也可以动态调用

## Ord & PartialOrd

这两个 Traits 的名称实际上来自于抽象代数中的「等价关系」和「局部等价关系」

二者的都实现了

- 对称性(Symmetry): a==b可推出b==a
- 传递性(Transitivity): a==b,b==c可推出a==c

Eq多实现了反身性(Reflexivity): a==a

为什么PartialOrd的返回值是Option<T>? 是为了考虑lhs是None的情况

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
