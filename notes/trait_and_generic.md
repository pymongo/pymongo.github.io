# trait

trait借鉴了很多Haskell的typeclass的概念，可以静态生成，也可以动态调用

简单来说trait是对类型行为的抽象

## trait静态/动态分发

简单来说impl Trait就是静态分发，dyn Trait就是动态分发(运行时查表)

## trait/Rust如何实现多态

多态指的是同一种行为，在不同上下文会相应不同的行为实现

Rust有两种多态的实现方法，一种是通过泛型静态分发，另一种是运行时查表的动态分发

Rust没有继承的概念，Rust实现多态的过程跟Java的向上塑型(upcast)不太一样

多态本身也是泛型的一种实现，Rust通过dyn关键字去定义一个实现了某个trait的类型，例如函数的入参里可以通过dyn Animal表示该参数必须实现了Animal Trait

除了dyn，也可以通过泛型T: Animal去实现多态

这提现了Rust 组合(mixin)优于继承、面向接口编程的编程思想

(当然dyn的缺点也有，运行时查表带来额外的性能开销，例如额外的存储空间，而且let语句也不能自动推断类型)

Rust的静态多态实现请看「trait和泛型的区别」一节

## ★trait和泛型的区别

泛型可以认为是「参数化多态/(staic多态)」，可以让类型或函数适用于多种不同类型避免重复代码

而参数化多态依赖于trait去实现，trait简单来说是对类型行为的抽象，trait可以为泛型添加约束条件和行为，也就是trait bound

如果一个泛型就一个光秃秃的T，没有任何trait bound，那它也不算泛型了，因为「啥也干不了」

这就是我对泛型和trait的理解

## Ord & PartialOrd

这两个 Traits 的名称实际上来自于抽象代数中的「等价关系」和「局部等价关系」

二者的都实现了

- 对称性(Symmetry): a==b可推出b==a
- 传递性(Transitivity): a==b,b==c可推出a==c

Eq多实现了反身性(Reflexivity): a==a

为什么PartialOrd的返回值是Option<T>? 是为了考虑lhs是None的情况

## readelf工具查看二进制文件中泛型/多态的符号

Linux: readelf, Mac: binutils

# generic

## const generic

Rust暂不支持，所以数组不支持impl <T, const N> for \[T; N]，如果支持的话操作定长度的数组的体验会有极大的提升 
