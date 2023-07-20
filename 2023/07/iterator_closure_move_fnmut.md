# [iter::once 避免 move](/2023/07/iterator_closure_move_fnmut.md)

```rust
if let Err(err) = KCIStmtPrepare(
    stmt,
    err,
    sql.as_ptr(),
    sql.len() as _,
    KCI_NTV_SYNTAX,
    KCI_DEFAULT,
)
.err(err)
{
    return Box::new((0..1).map(|err| Err(err)));
}
```

```
error[E0507]: cannot move out of `err`, a captured variable in an `FnMut` closure
  --> src/connection/impl_fetch.rs:29:49
   |
19 |     if let Err(err) = KCIStmtPrepare(
   |                --- captured outer variable
...
29 |         return Box::new((0..1).map(move |_| Err(err)));
```

没办法按照迭代器的方法签名要求 FnMut 不能这样 Mut

按照我的经验解决办法是尽量像 fold 那样把状态塞入到迭代器中从而尽量减少使用 move

> return Box::new(vec![err].into_iter().map(|err| Err(err)));

参考 stream::once 我找到了 iter::once 写出更优雅的版本

> return Box::new(std::iter::once(Err(err)));
