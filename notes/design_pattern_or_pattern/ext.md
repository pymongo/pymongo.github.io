# ext pattern

结构体或 trait 命名带 **Ext 后缀**或 **Extension 后缀**的可以统称为 Ext pattern

主要分为两种 Ext 用法: trait xxxExt 和 struct xxxExt

## 常见于

用以下正则表达式可以在 Rust 源码中搜到很多例子

- `trait \w+Ext \{`
- ``

## 作用 1. 为其他库的结构体扩展方法

例子 1.0:

Ruby rails/active_record 的 [camelcase](https://api.rubyonrails.org/classes/String.html#method-i-camelcase)

例子 1.1:

futures::FutureExt 扩展了标准库 Future 的方法

例子 1.2:

```rust
// ruby 的 rails/active_record 框架借助 extends 帮标准库字符串扩展了 驼峰命名转换的方法
trait StringExt {
    fn to_camel_case() -> Self;
}
impl StringExt for String {
    fn to_camel_case() {
        todo!()
    }
}

// 如果不用 Ext pattern，对 String 进行一系列操作
// 容易看错成 to_lowercase() 之后调用 repeat 看起来很乱可读性不佳
d(b(string.to_lowercase()).repeat(3));

// 使用 StringExt 能让所有方法的调用变成 field_access_expression
// 使得 to_lowercase()->b()->repeat(3)->d() 的链式调用过程一目了然
string.to_lowercase().b().repeat(3).d()
```

好处: 用 trait 将同一类型的扩展方法进行整合管理，可以链式调用可读性更强

缺点: IDE 代码跳转支持不好，rust-analyzer 对 trait 方法代码不能跳转到具体实现，Intellij-Rust 只能说部分支持 trait 方法实现的精准跳转

## 作用 2. 为特定操作系统扩展方法

标准库到处可见为 Linux/Unix 定制的各种 Ext trait

例子 2.1:

pub trait PermissionsExt // library/std/src/os/unix/fs.rs

## 作用 3. 多个结构体共用字段

例子 3.1:

pub arg_ext: ArgExtension // compiler/rustc_target/src/abi/call/mod.rs

### sum type 结构体共用字段

最近群里老有人问 Rust 怎么让多个结构体共用字段，其实无非就 product_type(积类型) + sum_type(和类型) 轻松解决的问题

我学了那么多语言也就 Haskell 和 Rust 有 sum type，所以以前写 Java/Golang/Python 不清楚 enum 的和类型抽象能力也属正常

Java 里面没有 sum_type/tagged_union 的抽象，用 extends 或 Interface 实现的"人类可以是老师或者是学生"抽象  
(但即便是 Interface 依然无法实现类型必须是 Teacher 或 Student 二选一的和类型抽象)

```java
class PersonCommonFields {
    private String name;
    private long created_at;
    private long updated_at;
}
class Teacher extends PersonCommonFields {
    private String teach_class;
}
class Student extends PersonCommonFields {
    private String school_name;
}
```

Rust 里面一般都用 Ext/Extension 的 enum 实现人类有老师或者学生两种情况的抽象

可以学下 Rust 源码的 compiler/rustc_target/src/abi/call/mod.rs 文件中的 enum ArgExtension

学下如何用一个和类型映射 LLVM 的好几种 Arg 情况

```rust
struct Person {
    name: String,
    created_at: libc::time_t,
    updated_at: libc::time_t,
    ext: PersonExt
}
enum PersonExt {
    Teacher { teach_class: String },
    Student { school_name: String }
}
```

Rust 共用字段方法二可以参考 syn 源码通过「元编程/依赖注入」codegen 的方式自动生成共有字段的结构体

---

## TODO write pattern
- singleton
- arena
- DI(codegen)
- marker
