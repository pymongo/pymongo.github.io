## poem_openapi::OpenApi/async_graph::Object 如何做到嵌套属性宏

首先 `#[proc_macro_attribute]` 用于 rustc_ast/syn 的 ImplItem

目前好像只有 derive 宏可以拥有嵌套的属性例如 `#[proc_macro_derive(Enum, attributes(oai))]`

因为嵌套的属性宏可以将外层宏的属性通过"上下文"往下游传递比较方便好用

poem_openapi::OpenApi 用到了一种特殊的「设计模式」

解析 ImplItem::Method 的函数属性宏时候，remove 掉 ImplItem 函数的 oai 属性宏

这样最终的代码实际上是不存在 `#[oai]` 的属性宏

remove_oai_attr 避免了 not found oai attr macro in current scop

精髓在于 parse_oai_attr 和 remove_oai_attr 的两个函数中

## ItemImpl 的属性宏的 FromMeta 结构体字段别有 `#[allow(dead_code)]`

如果其中一个字段是 `#[allow(dead_code)]` 可能导致 rust-analyzer **误报** `unresolve macro` 导致整个 impl 代码块一大片红色"报错"

但也可能是 rust-analyzer 旧版的 Bug

用 `syn::parse_macro_input!` 似乎比 `syn::parse` 更容易解决**误报问题**

## syn 的 extra-traits feature

~~当作为过程宏库的依赖时~~ syn 的 item 要通过 `extra-traits` feature 开启 Debug 功能

方便逐层对 AST 进行解包和拆分
