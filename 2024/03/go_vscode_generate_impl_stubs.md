# [Go generate interface](/2024/03/go_vscode_generate_impl_stubs.md)

Rust trait can have methods with the same name, and a struct can implement those traits with different implementations for each method. This is possible because Rust uses scoped naming for trait methods.

However, Go does not support this kind of method overloading. In Go, the method set of a type determines the interfaces it implements. Each method in a type's method set has a unique non-blank method name, and if two interfaces define a method with the same name, a type implementing that method will implement both interfaces with the same implementation

说白了就两个trait/interface有个 方法名签名 完全相同的函数，在rust中式两个不同实现的函数，而在Go中是同一个

如果interface很长很多方法，可以用一下办法像rust/java生成impl

vscode Go **generate interface stubs** (go impl)

语法是 self(也就是Self自身的参数名) struct_name interface_name

另一个常用的 vscode go 指令是清除 unused import **Organize imports**

## embedding/composite interface

```go
type InterfaceA interface {
    MethodA()
}

type InterfaceB interface {
    MethodB()
}

type InterfaceC interface {
    InterfaceA
    InterfaceB
}
```

---

Go generate interface stubs 踩坑记

我vscode go用 `self struct trait` 生成了一堆实现函数，可写代码时遇到staticcheck警告 ineffective assignment

原来是结构体体积大建议用pointer receiver 我只好默默删掉所有生成的代码，self改成&self重新生成一遍

原来Go并不能像Rust那样强制所有trait实现必须用&self引用


interface A有个方法是a，Go中用传值或者传引用去操作结构体都可以

在Rust中并不能，各有利弊
我可能会trait中定义三个函数a_ref(&self) a(self) a_ref_mut_(&mut self)
对于体积小的结构体实现a函数传值move语义效率更高
对于体积大的结构体实现a_ref
Go的interface 让使用者自行决断传引用还是传值


Go和Rust的trait差异除了没有强制约束传值传引用之外

第二个差异我觉得是两个trait有一个签名完全一样的函数 <A as B>::name 和 <A as C>::name 在 Rust 中是两个不同的函数，在Go中是同一个函数

Go写了函数就可能自动给结构体实现了某个我未知的interface，带来了方便也丧失了一些封装性
