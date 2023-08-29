# [再学 Rust for Linux](/2023/08/rust_for_linux.md)

## 别浪费时间搞 out-of-tree-module
一年前我写过文章探索 r4l out of tree module 编译(毕竟这样方便点用少量文件完成构建，不用在 linux 源码中构建只能 qemu 执行)，现在 Manjaro 也有 6.1 内核了先试试看

```
origin	https://github.com/Rust-for-Linux/rust-out-of-tree-module.git (push)
[w@ww rust-out-of-tree-module]$ zcat /proc/config.gz | grep _RUST
CONFIG_HAVE_RUST=y
[w@ww rust-out-of-tree-module]$ make
make -C /lib/modules/`uname -r`/build M=$PWD
warning: the compiler differs from the one used to build the kernel
  The kernel was built by: gcc (GCC) 13.2.1 20230801
  You are using:           clang version 15.0.7
  RUSTC [M] /home/w/repos/learningOS/rust-out-of-tree-module/rust_out_of_tree.o
error: target file "./rust/target.json" does not exist
```

好吧，文档说了必须要有 `CONFIG_RUST=y` 选项我放弃了，再看看这位老哥的两篇文章编译内核开启选项也没能解决 <https://blog.rnstlr.ch/building-an-out-of-tree-rust-kernel-module-part-two.html>

## kernel config
mka

以图形化的内核配置为例，方括号是只能选 y/n 尖括号的话还能选 m 也就是编译成模块但不嵌入到内核



## include/linux/drive.h
内核入口函数 main.c start_kernel

设备是一个树，注意总线本身也是一个设备，是所有设备的根

### platform 虚拟总线


### coherent_dma_mask
设备的寻址范围很可能小于 64 位内存，所以要一个 mask 过滤出设备自身寻址

### 一致性 DMA
一致性DMA的概念涉及到设备和系统内存之间的数据一致性。在多核处理器系统中，不同的处理器（或设备）可能有各自的高速缓存，数据被存储在这些缓存中并可能不同步更新到主内存中。这就可能导致设备访问的数据与主内存中的数据不一致。一致性DMA的目标是确保设备访问的数据与主内存中的数据一致。

## 术语表

|||
|---|---|
|libdrm.so|图形驱动相关 Direct Rendering Manager|
