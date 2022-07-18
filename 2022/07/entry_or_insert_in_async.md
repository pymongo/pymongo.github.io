# [Map::entry 异步时的坑](/2022/07/entry_or_insert_in_async.md)

之前遇到加了读写锁往 map 插入唯一 inode 之后，第二次请求仍然认为 map 中不存在这个 inode 的 key 会重复创建并插入的情况

```rust
let mut mapping = ctx.mapping_rwlock.write();
let kernel = mapping
    .entry(inode)
    .or_insert(Arc::new(KernelEntry::new(req.header.clone(), ctx).await?));
```

我也不太理解都 Arc+RwLock 依然似乎有重复写的情况，然后我展开 entry or_insert 后加入点 tracing 似乎又好了

```rust
/* entry.or_insert 带 async 代码的坑
在 tokio work_thread 数量较低时，由于 async 调度用 entry.or_insert 可能第二次请求会先执行 KernelEntry::new 再执行 entry
let kernel = mapping
    .entry(inode)
    .or_insert(Arc::new(KernelEntry::new(req.header.clone(), ctx).await?));
*/
let kernel = match mapping.entry(inode) {
    std::collections::hash_map::Entry::Occupied(v) => {
        tracing::trace!("inode {inode} found in mapping, return it");
        v.into_mut()
    }
    std::collections::hash_map::Entry::Vacant(v) => {
        tracing::debug!("inode {inode} not found in mapping, create new kernel");
        v.insert(Arc::new(
            KernelEntry::new(req.header.clone(), req.resource, ctx).await?,
        ))
    }
};
```

可能是 release 编译优化的 bug 每个分支加了 tracing 让他跑起来然后优化结果就不一样，之前折腾了很久了还是有必要记下下次出错也能查查

rustcc 编译 LLVM 优化 bug 的汇报帖子: <https://rustcc.cn/article?id=5ce9c30f-ba97-495a-8520-96353c827727>
