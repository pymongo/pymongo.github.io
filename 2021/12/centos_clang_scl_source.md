# [centos - scl_source](2021/12/centos_clang_scl_source.md)

例如装一些 llvm 的工具链之后 yum install -y devtoolset-7-llvm

Rust 编译 rocksdb 还是报错 clang 找不到

centos 好像在 root 用户下才把 clang 之类的加到 PATH, 新创建的用户需要 scl_source 一下才能把 llvm 的工具加到 PATH

(更新: 这是 centos7 的问题，centos 8 可以直接装 lld 不用加 scl_source 源)

---

```
yum install -y epel-release centos-release-scl
```

```
已安装:
  llvm-toolset-7.x86_64 0:5.0.1-4.el7

作为依赖被安装:
  devtoolset-7-binutils.x86_64 0:2.28-11.el7           devtoolset-7-gcc.x86_64 0:7.3.1-5.16.el7        devtoolset-7-gcc-c++.x86_64 0:7.3.1-5.16.el7 
  devtoolset-7-libstdc++-devel.x86_64 0:7.3.1-5.16.el7 devtoolset-7-runtime.x86_64 0:7.1-4.el7         llvm-toolset-7-clang.x86_64 0:5.0.1-4.el7    
  llvm-toolset-7-clang-libs.x86_64 0:5.0.1-4.el7       llvm-toolset-7-compiler-rt.x86_64 0:5.0.1-2.el7 llvm-toolset-7-libomp.x86_64 0:5.0.1-2.el7   
  llvm-toolset-7-lldb.x86_64 0:5.0.1-4.el7             llvm-toolset-7-llvm.x86_64 0:5.0.1-8.el7        llvm-toolset-7-llvm-libs.x86_64 0:5.0.1-8.el7
  llvm-toolset-7-python2-lit.noarch 0:0.5.1-1.el7      llvm-toolset-7-runtime.x86_64 0:5.0.1-4.el7    

完毕！
[root@localhost aoxiang]# clang
-bash: clang: 未找到命令
[root@localhost aoxiang]# source scl_source enable llvm-toolset-7
[root@localhost aoxiang]# clang
clang-5.0: error: no input files
```

为了编译带 librocksdb 的 Rust 项目， centos OS 需要安装
- epel-release (optional?)
- centos-release-scl // add `scl_source enable llvm-toolset-7` to ~/.bashrc
- llvm-toolset-7
- base-devel gcc-c++


- clang 或 devtoolset-7-llvm ?
