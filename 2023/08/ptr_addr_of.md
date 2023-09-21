# [ptr::addr_of!](/2023/08/ptr_addr_of.md)

addr_of! 宏除了读取 repr(packed) 的结构体我还没想到有什么用

对应 C 语言类似的是 **offset_of** 宏

## container_of

obtain a pointer to the parent structure given a pointer to one of its members

常用于 linux 源码例如 watchdog_context 里面有个 watchdog_devicewatchdog_ops

在 **Rust for Linux 源码中实现了这两个 C 的宏** <https://rust-for-linux.github.io/docs/kernel/macro.container_of.html>
