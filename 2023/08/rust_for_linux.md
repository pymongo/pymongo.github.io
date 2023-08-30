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

更新: 当我 r4l 源码 make 成功后，加上 KDIR 重新构建

```
[w@ww rust-out-of-tree-module]$ make KDIR=../linux/
make -C ../linux/ M=$PWD
  RUSTC [M] /home/w/repos/learningOS/rust-out-of-tree-module/rust_out_of_tree.o
error[E0050]: method `init` has 1 parameter but the declaration in trait `kernel::Module::init` has 2
  --> /home/w/repos/learningOS/rust-out-of-tree-module/rust_out_of_tree.rs:20:22
   |
20 |     fn init(_module: &'static ThisModule) -> Result<Self> {
   |                      ^^^^^^^^^^^^^^^^^^^ expected 2 parameters, found 1
   |
   = note: `init` from trait: `fn(&'static kernel::prelude::CStr, &'static kernel::ThisModule) -> core::result::Result<Self, kernel::Error>`

error: aborting due to previous error


[w@ww rust-out-of-tree-module]$ make KDIR=../linux/
make -C ../linux/ M=$PWD
  RUSTC [M] /home/w/repos/learningOS/rust-out-of-tree-module/rust_out_of_tree.o
  MODPOST /home/w/repos/learningOS/rust-out-of-tree-module/Module.symvers
  CC [M]  /home/w/repos/learningOS/rust-out-of-tree-module/rust_out_of_tree.mod.o
  LD [M]  /home/w/repos/learningOS/rust-out-of-tree-module/rust_out_of_tree.ko

sudo insmod ./rust_out_of_tree.ko
insmod: ERROR: could not insert module ./rust_out_of_tree.ko: Invalid module format
```

dmesg 报错日志:

> [314501.389747] rust_out_of_tree: version magic '6.3.0-g18b749148002 SMP preempt mod_unload ' should be '6.1.44-1-MANJARO SMP preempt mod_unload '

## kernel config

```
rustup override set $(scripts/min-tool-version.sh rustc)
rustup component add rust-src
cargo install -f --locked --version $(scripts/min-tool-version.sh bindgen) bindgen
bindgen --version
make LLVM=1 rustavailable

make menuconfig
# enable genernal->rust_support
# enable kernel_hacking->samples->rust

[w@ww linux]$ cat .config | grep _RUST
CONFIG_RUST_IS_AVAILABLE=y
CONFIG_RUST=y
CONFIG_HAVE_RUST=y

make -j$(nproc)
file vmlinux
```

以图形化的内核配置为例，方括号是只能选 y/n 尖括号的话还能选 m 也就是编译成模块但不嵌入到内核

## vscode ra&clangd
```
make LLVM=1 rust-analyzer # would generate rust-project.json? 其实是 make 内核之后也会生成

cat .vscode/settings.json
{"rust-analyzer.linkedProjects": ["rust-project.json"]}
```

clang 配置 <https://docs.qq.com/doc/DY0ZJZXhxZkNXZ3FH> 不用 bear 70% 的定义也能跳转，但例如 drivers/base/driver.c 里面 klist_next 找不到定义

以下是 gpt 的 linux 源码 clangd 配置，跟 r4l 课程文档一样也是需要用 bear

```
创建一个名为.clangd的文件夹，并进入该文件夹。
在.clangd文件夹中创建一个名为compile_commands.json的编译数据库文件。这个文件将用于为clangd提供编译信息。你可以使用Bear工具来生成编译数据库，具体操作可以参考前面提到的Bear工具的使用方法。
在.clangd文件夹中创建一个名为clangd.yaml的配置文件。这个文件将用于配置clangd的行为。
打开clangd.yaml文件，并根据你的需求进行配置。你可以配置诸如编译器路径、标准库路径、头文件搜索路径、代码风格等选项。具体的配置选项可以参考clangd的文档。
在代码仓库的根目录中执行以下命令启动clangd：clangd --compile-commands-dir=.clangd。这会告诉clangd在.clangd文件夹中查找编译数据库文件。
```

> bear -- make LLVM=1 -j$(nproc)

没用 bear ，即便用了以下 clangd 配置依然是只能解析 6-7 成符号，用了 bear 生成几十万行的 compile_commands.json 之后符号

```
{
    "rust-analyzer.linkedProjects": [
        "rust-project.json"
    ],
    "clangd.arguments": [
        "--compile-commands-dir=${workspaceFolder}",
        "--background-index",
        "--completion-style=detailed",
        "--header-insertion=never",
        "-log=info"
    ]
}
```

> linux 6.0 的源码已经超过两千万行了，即便是 understand 软件精简掉除 x86 以外代码的示例项目 ~/.config/SciTools/samples/linuxKernel/ 也是百万行

## busybox 与 initrd

> initrd是一个用于引导Linux内核的临时文件系统。它是一个包含根文件系统所需文件的初始 RAM 磁盘映像。initrd在引导过程中被加载到内存中，以便在启动时提供文件系统支持，用于加载必要的驱动程序、模块和其他文件，以使系统能够成功引导。一旦Linux内核启动并加载了真正的根文件系统，initrd就会被卸载并释放掉

```
创建文件系统目录：在你的工作目录下创建一个用于构建文件系统的目录，例如rootfs
$ cd rootfs
$ mkdir -p proc sys dev etc/init.d
$ mkdir -p etc/network
$ touch etc/passwd etc/group etc/fstab etc/network/interfaces
$ chmod a+rwX -R .
添加必要的配置：根据你的需求，编辑etc/fstab、etc/network/interfaces等文件，配置文件系统的挂载和网络设置
复制BusyBox可执行文件：在编译BusyBox时生成的可执行文件保存在BusyBox的输出目录中。将busybox可执行文件复制到rootfs目录下：
$ chroot rootfs /busybox sh
$ ln -s /busybox /bin/sh
$ mknod dev/console c 5 1
$ mknod dev/null c 1 3
安装BusyBox的applets：在chroot环境中运行BusyBox的install命令来安装applets。这将在rootfs目录下创建链接，使得这些applets可以在文件系统中使用：
/busybox --install -s
```

1. busybox 的 make menuconfig 记得开 Settings->Build BusyBox as a static binary
2. make -j($nproc)
3. make install

```
$ ls ../busybox/_install/
bin  linuxrc  sbin  usr

../busybox/_install/
├── bin
│   ├── arch -> busybox
│   ├── ash -> busybox
│   ├── base32 -> busybox
│   ├── base64 -> busybox
│   ├── busybox
│   ├── cat -> busybox
...

[w@ww src_e1000]$ busybox pwd
/home/w/repos/learningOS/stage3_homework/src_e1000
[w@ww src_e1000]$ ldd /bin/busybox
        not a dynamic executable
```

所以说所有可执行文件其实都是 static link 的 busybox 一个通过 argv[0] 判断执行哪个可执行文件的逻辑

最后用 cpio 将 rootfs 打包成一个文件

### /etc/init.d/rcS
开机初始化会执行的一段脚本，在 E1000 网卡驱动实验中是如下的内容

```
#!/bin/sh
mount -t proc none /proc
mount -t sysfs none /sys
#mount -t debugfs none /sys/kernel/debug

# /sbin/mdev -s 命令会启动 mdev 守护进程，它负责监听 /sys 目录下的设备事件，并根据设备事件的发生情况来加载和配置相应的设备驱动
/sbin/mdev -s
```

## poweroff/halt 关机
busybox 工具里面没有 shutdown, 关机用 poweroff, halt 关机后 qemu 虚拟机不会退出
```
~ # halt
~ # umount: can't unmount /: Invalid argument
swapoff: can't open '/etc/fstab': No such file or directory
The system is going down NOW!
Sent SIGTERM to all processes
Sent SIGKILL to all processes
Requesting system halt
[   48.029209] reboot: System halted
```

!> 注意 halt 跟 riscv 的 wfi 指令进入低功耗等中断待机模式不是一回事

## out-of-tree-module ra&clangd

---

以下是理论知识和源码解读

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
