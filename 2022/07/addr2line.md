# [addr2line](/2022/07/addr2line.md)

在没有 coredumpctl 和 /proc/sys/kernel/core_pattern 的环境下发生 SIGSEGV 段错误后

只能在 dmesg 看到，addr2line 是一个分析 dmesg 中段错误行号的工具

> a.out[75099]: segfault at 0 ip 00000000004004dd sp 00007fff70904d50 error 6 in a.out[400000+1000]

去看寄存器 IP(Instruction Pointer) `addr2line 00000000004004dd` 发现返回 `??:?` 没有 debuginfo 符号信息

于是 gcc -g 参数加上 debuginfo 再来一次

> a.out[75938]: segfault at 0 ip 00000000004004dd sp 00007fffbcbfa4e0

addr2line 的 --exe 参数默认是 ./a.out

!> 跟 gdb 看 coredump 文件一样需要给个可执行文件作为参数才能看到符号

```
addr2line 00000000004004dd
/root/c.c:3

addr2line --functions --demangle 00000000004004dd
main
/root/c.c:3
```

```cpp
int main() {
    int *p = 0;
    *p = 1;
    return 0;
}
```

但是用 rustc -g r.rs 编译以下代码不知为何原因还是看不到符号和行号

```rust
fn main() {
    unsafe { std::ptr::null_mut::<i32>().write(1) };
}
```

就跟 gcc -pg 的 gprof 工具在 Rust 都用不了，只能说 Rust 只能用 c 生态部分内容
