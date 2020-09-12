# 元编程与宏

通过以下命令查看Rust代码被编译器解析成的AST(Abstract Syntax Tree)，注意不是过程宏入参的那个TokenStream

> rustc +nightly -Z ast-json temp.rs

如果是在一个cargo项目内可以用

> cargo rustc -- -Z ast-json

AST可以联想成Lisp的S表达式那样自底向上的二叉树似的执行顺序