# [centos - scl_source](2021/12/cenos_clang_scl_source.md)

例如装一些 llvm 的工具链之后 yum install -y devtoolset-7-llvm

Rust 编译 rocksdb 还是报错 clang 找不到

centos 好像在 root 用户下才把 clang 之类的加到 PATH, 新创建的用户需要 scl_source 一下才能把 llvm 的工具加到 PATH

```
yum install -y epel-release centos-release-scl
source scl_source enable llvm-toolset-7
```
