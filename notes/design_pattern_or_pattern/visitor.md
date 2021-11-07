# Visitor design pattern

## 作用
方便调用方对**树状数据结构**的遍历，codegen/过程宏写的越多就越能理解 syn::visitor::Visit 的精髓

## 常用
- 编译器/数据库 parser 代码的 AST 遍历
- 对外提供复杂树状数据结构的同时建议也提供该树状结构的 Visitor

## 常见于 Stmt/Expr
- `trait Visitor`
- `fn visit_expr()`, `fn walk_xxx()`

## examples
- pub trait Visitor<'ast> // syn::visit
- pub trait Visitor<'ast> // rustc_ast::visit
- pub fn walk_expr_field // rustc_ast::visit

## See also
- syn::fold::Fold, and Fold pattern on AST
