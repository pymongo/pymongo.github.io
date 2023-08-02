# [Vec::push FFI 内存错误](/2023/08/vec_push_mem_addr_change_cause_ffi_fail.md)

这样一段绑定数据库查询结果 buffer 的 FFI 调用代码发生了内存错误，期望是查询结果为 NULL 的时候 val_is_null flag 会被数据库动态库设置成 -1，然而 val_is_null 这个值并没有改

```rust
for i in 0..num_fields {
    let column = Column {
        val_buf: vec![0u8; size],
        val_is_null: 0,
    };
    KCIDefineByPos(
        column.val_buf.as_mut_ptr().cast(),
        i32::try_from(column.val_buf.len()).unwrap(),
        ((&mut column.val_is_null) as *mut i16).cast(),
    )
    .err(err)?;
    columns.push(column);
}
```

怀疑跨函数 move Columns 会改变内存地址，然后打印了下确实 move 没有修改地址，而且 columns 是个 vector 本身就分配到堆上

于是我把 val_is_null 设置成 **static** 就解决了问题，遇到 NULL 查询结果能正常被修改成 -1

最终发现原来问题出自 Vec::push 后 val_is_null 的内存地址变了(从栈上变成堆上)

```rust
let column = Column {
    val_buf: vec![0u8; size],
    val_is_null: 0,
};
dbg!(&column.val_is_null as *const i16 as usize);
columns.push(column);
dbg!(&columns[i].val_is_null as *const i16 as usize);
```

所以等 `columns.push(column);` 内存地址修改完后再把 val_is_null 的内存地址传给 FFI 调用就解决了
