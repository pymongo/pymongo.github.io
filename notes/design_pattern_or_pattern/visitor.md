# Visitor design pattern

## 作用
方便调用方对**树状数据结构**的遍历，codegen/过程宏写的越多就越能理解 syn::visitor::Visit 的精髓

## 常用
- 编译器/数据库 parser 代码的 AST 遍历
- clippy Lint 的各个回调就是通过 Visitor 实现
- 对外提供复杂树状数据结构的同时建议也提供该树状结构的 Visitor

## 常见于 Stmt/Expr
- `trait Visitor`
- `fn visit_expr()`, `fn walk_xxx()`

## examples
- pub trait Visitor<'ast> // syn::visit
- pub trait Visitor<'ast> // rustc_ast::visit
- pub fn walk_expr_field // rustc_ast::visit
- [servo 源码用的 syn::visit](https://github.com/servo/servo/blob/a3af32155fe74ab886862a56a75af06dee9ea9d5/components/style_derive/to_css.rs#L111)
- [rustc_lint 的各种回调就是通过 visit 实现](https://github.com/rust-lang/rust/blob/46b8e7488eae116722196e8390c1bd2ea2e396cf/compiler/rustc_lint/src/early.rs#L83>)

## Read more
- https://github.com/ZhangHanDong/real-world-rust-design-pattern/blob/main/src/visitor.md

## See also
- syn::fold::Fold, and Fold pattern on AST
