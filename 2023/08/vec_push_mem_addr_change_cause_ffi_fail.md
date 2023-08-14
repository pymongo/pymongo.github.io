# [Vec 动态扩容悬垂裸指针](/2023/08/vec_push_mem_addr_change_cause_ffi_fail.md)

这样一段绑定数据库查询结果 buffer 的 FFI 调用代码发生了内存错误，字段的查询结果为 NULL 的时候 val_is_null flag 会被数据库动态库设置成 -1，然而出现了内存错误 val_is_null 这个值并没有改

## Vec::push 栈->堆 导致悬垂指针

传递给动态库的可变指针没有被修改，很容易想到是不是发生了悬垂引用现象

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

最终发现原来问题出自 Vec::push 后 val_is_null 的内存地址变了(从<var class=mark>栈上</var>变成<var class=mark>堆上</var>)

```rust
// val_is_null alloc on stack
let column = Column {
    val_buf: vec![0u8; size],
    val_is_null: 0,
};
// pass stack pointer to FFI
unsafe { ffi_pass_ptr(&val_is_null); }
dbg!(&column.val_is_null as *const i16 as usize);

columns.push(column);
dbg!(&columns[i].val_is_null as *const i16 as usize);
```

所以等 `columns.push(column);` 内存地址修改完后再把 val_is_null 的内存地址传给 FFI 调用就解决了

## 数组动态扩容内存重新分配导致指针地址变化

当我以为内存问题解决完之后，测试时发现超过 30 个字段的大型 sql 查询依然发生 SIGABRT/SIGSEGV

沟通国产数据库动态库的技术支持说我们代码中绑定传入的指针地址跟查询的时候的指针地址不一样

```
[src/connection/impl_fetch.rs:236] i = 0
[src/connection/impl_fetch.rs:236] &columns[0].val_is_null as *const i16 as usize = 139814338896636
[src/connection/impl_fetch.rs:236] i = 1
[src/connection/impl_fetch.rs:236] &columns[0].val_is_null as *const i16 as usize = 139814338896636
[src/connection/impl_fetch.rs:236] i = 2
[src/connection/impl_fetch.rs:236] &columns[0].val_is_null as *const i16 as usize = 139814338896636
[src/connection/impl_fetch.rs:236] i = 3
[src/connection/impl_fetch.rs:236] &columns[0].val_is_null as *const i16 as usize = 139814338896636
[src/connection/impl_fetch.rs:236] i = 4
[src/connection/impl_fetch.rs:236] &columns[0].val_is_null as *const i16 as usize = 139814338962876
[src/connection/impl_fetch.rs:236] i = 5
```

埋点看日志发现，每当 Vec 第五次 push Column 的时候必定复现判断返回值是否为 NULL 的标志位指针 val_is_null 地址发生变化

再次跟动态库的技术支持扯皮踢皮球，对方很确定调用他们没有修改指针地址

于是我想 48 48 这个数字有什么玄学，马上联想起 Java 背诵的八股文里面说过 HashMap 容量超过 4/8 默认容量的时候会发生扩容

问了下 gpt `Rust vector 扩容的时候，vec内元素的内存地址会发生变化吗`

```
在Rust中，当扩容Vector（`Vec`）时，向量内元素的内存地址可能会发生变化。这是因为`Vec`使用动态数组实现，而在进行扩容时，需要重新分配更大的内存块，并将现有元素复制到新的内存块中。在扩容期间，`Vec`会首先分配一个新的内存块，然后将现有元素从旧的内存块复制到新的内存块。一旦所有元素都成功复制到新的内存块中，旧的内存块将被释放。由于内存块的地址不同，所以在扩容后，向量内元素的内存地址可能会发生变化。这意味着之前获取的元素的引用或指针可能会失效，因为它们引用的内存地址已经改变。因此，在扩容`Vec`后，如果持有旧的引用或指针，请小心处理，确保它们仅在扩容之前使用，以避免悬空引用或指针错误。需要注意的是，即使内存地址发生变化，向量中的元素顺序仍保持不变。只有元素的地址发生变化，但元素之间的相对顺序保持不变。
```

既然 sql prepare 之后就拿到查询返回的字段数量，我改成 Vec::with_capacity 之后果然解决了
