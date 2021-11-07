# Fold pattern

## 作用
<https://rust-unofficial.github.io/patterns/patterns/creational/fold.html>

根据 syn::fold module 的文档和 rust-unofficial 对 fold 模式的阐述，我理解 fold 有以下作用:
1. 克隆一棵树 (deep copy)
2. AST 树(根节点)转 HIR 树(有点像树版本的 .into_iter().map().collect())

当然 AST 树转 HIR 树只是举例 rust 源码中并未看到 Fold 模式的使用，对于作用 2 只能是两个相似的树结构体之间转换适合用 Fold

像 AST -> HIR 差异这么大的转换显然用 Fold 就力不从心会，格式转换的代码要写的很麻烦

## 常用
???

## examples
- pub trait Fold // syn::fold

## trait Fold different to Visitor

仅仅是 trait 中每个方法的返回值不同，Fold 要求返回相应 AST 节点而 Visitor 的返回值为空

## See also
- syn::visit::Visitor
