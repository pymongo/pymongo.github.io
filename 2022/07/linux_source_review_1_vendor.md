# [Linux 源码读后感1](/2022/07/linux_source_review_1_vendor.md)

最近从 Linux 源码构建 Rust 内核模块的过程中看了一些 Linux 源码加深理解内核配置参数

我的构建体验是 Linux 处于静态链接的需要很喜欢或者说不得不将一堆代码 vendor 进 codebase

所以关于 Linux 源码读后感之 vendor 话题我有一些读后感和想法向分享下

之前我写过文章 [第三方库的三种引入](/2022/07/three_way_import_third_party_lib.md)

Linux 源码貌似把 glibc 部分系统调用加上 strlen 之类 C 语言的常用方法都 vendor 进来

好的设计上 Linux 没有 git submodule 而 rust 源码一堆 submodule 个人就不太喜欢

例如某些 arm 的 arch 的 strlen 实现跟默认实现不一样的话，通过各种宏去实现 override 的效果

---

## Rust vendor

Linux 源码中 vendor 进来的 Rust 部分我还没完全看完，看上去把标准库中一半的篇幅都弄进来了，例如 alloc 等等

因构建需要相比 Rust 内核开发约等于 no_std 环境只能用 vendor 进来的那一部分代码

后续如果我对 vendor 进来的这部分 Rust 代码有更深入的理解的话就再更新此文把
