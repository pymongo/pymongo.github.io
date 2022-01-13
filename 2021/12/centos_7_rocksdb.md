# [librocksdb-sys on centos7](/2021/12/centos_7_rocksdb.md)

在 centos 7 (docker image) 编译 Rust librocksdb-sys 所需步骤

> docker run -it centos:7 bash

```bash
# install SCL repository to get llvm packages
yum install -y centos-release-scl

# would install `llvm-toolset-7` and `devtoolset-7` to /opt/rh
# devtoolset-7 include gcc/c++/ld binary
yum install -y llvm-toolset-7
echo "source scl_source enable llvm-toolset-7 devtoolset-7" >> ~/.bashrc

# optional, just for compile fast
yum install -y llvm-toolset-7.0-lld
echo "source scl_source enable llvm-toolset-7.0" >> ~/.bashrc

# ignore rustup install ...
```

!> 注意 centos7 的 gcc 版本太旧 config.toml 的 linker 要选 clang 才能支持 lld

---

## 我个人建议用 source scl_source enable 不必写死路径 /opt/rh 前缀

```diff
- source /opt/rh/llvm-toolset-7.0/enable
+ source scl_source enable llvm-toolset-7.0
```
