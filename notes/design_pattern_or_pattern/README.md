design_pattern 翻译成设计模式，主要指行业公认的设计模式，狭义上指应用在 Java/C++ 的设计模式。例如 Visitor 设计模式

pattern 翻译成编程范式，主要是 Rust 语言特有设计带来的编程范式，例如 Rust 编程范式之 new type pattern 用于解决孤儿规则等应用领域

设计模式是在 1994 年有四个人写的 *Design Patterns: Elements of Reusable Object-Oriented Software* 书里面的 C++ 23 个经典设计模式，后经 Head First Design Patterns 广泛推广到 Java 中

Design Pattern:
- Builder

Rust Pattern【重点】:
- Arena
- Ext
- NewType

---

pattern_in_rustc_or_std.txt 算是一个简单的大纲

---

注 1: `xxx` 只是个占位符，例如 xxxBuilder 表示任意以 Builder 后缀的结构体名字

注 2: **常见于 Stmt/Expr** 几乎表示了 Rust 的所有语言项和表达式，例如 `Stmt::Item(ItemStruct)` 和 `ExprKind(PathExpr)`
