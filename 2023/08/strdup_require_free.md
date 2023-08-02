# [strdup 记得 free](/2023/08/strdup_require_free.md)

我问 gpt 复制字符串推荐用什么函数再加上最近遇到了 SIGABRT 报错，让我意识到项目用 strdup 发生了内存泄漏或重复释放

我问 gpt 为什么不推荐 strdup, gpt 说 strdup 和 strcpy 的唯一区别是前者 malloc 分配到堆上需要 free

(我用 strdup 的原因是想要复制动态库 static 区的一个字符串变量回来)

于是我用 `valgrind --leak-check=full` 检测以下代码有没有内存泄漏，果然 strdup 出现内存泄漏

```rust
fn main() {
    let s = [0u8; 8];
    unsafe {
        libc::strdup(s.as_ptr().cast());
    }
}
```

```
==3993443== HEAP SUMMARY:
==3993443==     in use at exit: 1 bytes in 1 blocks
==3993443==   total heap usage: 9 allocs, 8 frees, 1,974 bytes allocated
==3993443== 
==3993443== 1 bytes in 1 blocks are definitely lost in loss record 1 of 1
==3993443==    at 0x483B7F3: malloc (in /usr/lib/x86_64-linux-gnu/valgrind/vgpreload_memcheck-amd64-linux.so)
==3993443==    by 0x494738E: strdup (strdup.c:42)
==3993443==    by 0x11B3EC: memcheck::main (main.rs:4)
```

---

虽然 strdup->strcpy 并没有解决 SIGABRT 问题，但还是积累了一些解决 SIGABRT 的经验

> SIGABRT: memory allocation of 13510798882112328 bytes

这个内存分配错误原因是堆内存不够用了，一个 sqlx 查询 40 个字符串每个字符串都是两万的预分配长度，同时查询上百个记录

于是我把两万的预分配字符串长度减少到 256 就解决了

> SIGABRT: free(): invalid next size(fast)

我检查完所有 Rust 的 unsafe 块没发现问题，只能联系数据库驱动动态库的技术支持帮忙调查下
