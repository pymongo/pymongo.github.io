# [翻译RFC2000 const generic](/2020/10/rfc_const_generics.md)

我的翻译并不会按原文顺序逐字翻译，因为除了RFC的网页，还涉及相关PR和issues，以下是我对RFC#2000 const generic个人理解下的翻译

<https://rust-lang.github.io/rfcs/2000-const-generics.html>

首先动态语言为什么没有常量，因为常量是编译时编译器将常量的字面量替换到使用该常量的地方，这也叫「内联优化」

由于动态语言通过解释器来运行，没有编译的环节，所以无论是Python或Ruby不存在不可变的常量，甚至想让变量不可变都很难

在Rust和C语言里可以对函数加上inline标记使编译器对函数进行内联优化，也就是把函数内部的代码展开到函数调用处，这样能减少一次汇编语言层面上的函数调用，提升性能

因此const expr/const fn能让编译型语言在编译时得到性能优化，const generic是为了解决无法用trait/泛型复用原始数组代码的问题

相比于vector，原始数组的优点是直接在栈上分配内存，减少一次Vec胖指针的跳转/重定向

我首先看的是rust lang team(T-lang)在[internal threads上讨论的帖子](https://internals.rust-lang.org/t/lang-team-minutes-const-generics/5090)

帖子的楼主提到一旦定下了const generic的写法，就起草一个新的RFC，取代掉现有的RFC#1931

所以我注意到Rust的RFC并不是连号的原因，可能是有更优秀的RFC草案替代了之前的草案

const expr的主要问题是两个const expr之间的type checking

> A major issue is determining the equality of two constant expressions during typechecking. 

解决常量表达式之间的typechecking有两种方案: Unification(联合)和Overlap

## opaque type

> impl<const N: usize> Foo for [i32; {N * 2}] { }

> A consequence of treating {N * 2} as an opaque function is that given eg. <[i32; 4] as Foo> we cannot resolve the correct impl

看到这里的opaque function我想起了[opaque type](https://internals.rust-lang.org/t/lang-team-minutes-const-generics/5090)

例如以下代码会报错: expected &str, found opaque type

```rust
fn foo() -> impl ToString {
    "Hello, world!"
}
let _: &str = foo();
```

所以opaque function指的是这种写法{N*2}编译器无法知道具体impl了哪一个常量泛型

由于浮点数没有实现Eq(reflexive反身性，也就是证明a==a)，所以常量泛型不支持浮点数类型?

## Motivation

引入常量泛型的动机是，stdlib关于数组的Trait最大仅支持32的长度，例如我试着println一个长度为366的数组会编译报错

internal thread那篇T-lang的讨论帖子，我看了前10个reply就不想继续看了，含金量一般，都是各个大佬的一些对语法个人喜好的评论，例如不应该加分号

[关于const generic的使用可以看这个github仓库](https://github.com/Michael-F-Bryan/const-arrayvec/blob/master/src/lib.rs)

TODO
