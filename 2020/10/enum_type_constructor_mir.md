# [type constructor and mir](/2020/10/enum_type_constructor_mir.md)

今天看张汉东老师在极客时间上的视频的第11讲时，学到了原来带类型的eunm编译成MIR代码后每个类型都会变成一个函数，函数(fn item)实际上也是个类型构造器

例如我有一个验证POST请求表单的通用方法，如果中途没有发生Error，则返回枚举ValidResult，如果表单参数值的范围在业务逻辑内，则返回通过表单public_key查询到的user_id，否则返回错误提示String

```rust
enum ValidResult {
    UserId(u32),
    ErrMsg(String),
}

// enum类型构造器展开后的代码有那么点像C++impl类方法的代码
fn ValidResult::ErrMsg(_1: String) -> ValidResult {
    todo!("ellipsis")
}

fn ValidResult::UserId(_1: u32) -> ValidResult {
    todo!("ellipsis")
}
```

fn item实际上是个类型构造器(占0个字节)，例如输入一个u32，输出ValidResult

写代码时不到万不得已不要用函数指针类型，因为占8个字节，而fn item占0个字节拥有0大小类型优化

C++单入参的构造方法前要加上explicit的作用: 例如有个函数是foo(Node)，有一处调用是foo(1)，

如果不加explicit编译器会调用Node(int)构造方法去将1强制转换为Node实例对象，造成UB

## 为什么要学点MIR代码

所以Rust的高级抽象/零成本抽象，最终会把高级抽象变成C/C++语言

例如会把带类型的enum变成若干的函数，会把实例方法变成类方法再变成普通函数，这样就去掉了LLVM可能不认识的OOP抽象

所以rust实例函数的调用`p.get_x()`会变成MIR`Point::get_x(move _3)`，这是我看《Rust编程之道》时才学会的

我们可以通过MIR代码去加深了解Rust的一些抽象例如难以理解的协变，它编译成MIR后会是怎样的类"C"语言代码?

学习MIR的还有一个重要原因是，可以深入了解生命周期的本质

## 如何查看mir代码

```
% rustc | grep mir
        --emit [asm|llvm-bc|llvm-ir|obj|metadata|link|dep-info|mir]
```
所以\[cargo] rustc --emit mir main.rs 就能查看编译MIR阶段的代码

所以rustc编译器还是很强的，playground上展开成llvm-ir和asm汇编代码的原理就是出自emit参数

## playground的miri tool

主要排查MIR代码的内存安全吧，通过MIRI的MIR解释器解决了很多内存上的UB行为，对我来说有些晦涩难懂

## playground的expand tool

等同于nightly版本的`rustc -Zunstable-options --pretty=expanded`，另一个cargo expand的好处是有颜色高亮
