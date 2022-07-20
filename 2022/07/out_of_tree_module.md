# [out of tree module](/2022/07/out_of_tree_module.md)

最早 Rust-for-Linux 的设计确实想和 C 一样直接用 /lib/modules 用户系统自带的内核工具链，

例如这个 repo: <https://github.com/fishinabarrel/linux-kernel-module-rust>

但这个方法诸多问题导致 deprecated/archive 了我拿这个 repo 也完全无法 make

Rust for Linux 组织在 github 上提供了一个 out of tree module 的示例

通过 KDIR 环境变量指定内核工具链，默认是 /lib/modules/$(uname -r)/build

但我用默认位置依然不能编译，还是因为自己内核无 Rust 相关函数 symbol

而 KDIR 设置成 Rust-for-Linux 的则能编译不过出来的产物还是 5.19 的跟直接在 Rust-for-Linux 源码文件夹编译也没区别

所以结论还是:

- 编译本机可用的内核模块，只能用 C 语言连 /lib/modules 工具链去开发
- Rust 开发的内核模块只能用 qemo 运行测试

https://twitter.com/ospopen/status/1549391424734613506
