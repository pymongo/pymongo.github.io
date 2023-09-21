# [黑芝麻芯片内核编译踩坑](/2023/09/bst_chip_arm_linux_cross_compile.md)

## archlinux 内核编译踩坑

### archlinux dtc compile error

> make ARCH=arm64 LLVM=1 O=build -j24 WERROR=0 CROSS_COMPILE=aarch64-linux-gnu- V=1

CROSS_COMPILE 加不加似乎都没影响，都使用 clang 编译 dtc 的

```
../arch/arm64/boot/dts/bst/bsta100b.dtsi.. /arch/arm64/boot/dts/bst/bsta1000b. dtsi::1212::1010::fatal error: fatal error: 'dt-bindings/intrrupt-controller/arm-gic.h' file not found

../arch/arm64/boot/dts/bst/dt-bindings/interrupt-controller/arm-gic.h:9:10: fatal error: 'dt-bindings/interrupt-controller/irq.h' file not found
#include <dt-bindings/interrupt-controller/irq.h>
         ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
In file included from ../arch/arm64/boot/dts/bst/bsta1000b-fadb-chery.dts:5:
In file included from ../arch/arm64/boot/dts/bst/bsta1000b.dtsi:16:
```

[参考 NXP 社区这个求助帖子](https://community.nxp.com/t5/i-MX-Processors/IMX8QXP-linux-imx-build-failed/td-p/951084)

vim scripts/Makefile.lib

find dtc_cpp_flags and add realpath of ./include e.g. `-I/home/w/repos/learningOS/linux-rust/include`

### 高版本 gcc 需要去掉一些高版本的编译警告才能编译成功

会遇到以下这两个类似的报错应该都是类似高版本 rustc/clippy 会引入新的警告类型，但内核编译又是 deny(warnings) 那样禁止警告，所以我们需要加上 WERROR=0 环境变量忽略一些警告

```
../drivers/bst_coreip/genProtoCommon.c: In function ‘setup_init_parti’:
../drivers/bst_coreip/genProtoCommon.c:47:3: error: unsigned conversion from ‘long int’ to ‘unsigned char’ changes value from ‘4115’ to ‘19’ [-Werror=overflow]
   47 |   ((void *)&pInit->rodata_resv[0] - (void *)pInit) >> 5;

../drivers/gpu/drm/bst-vsp/bst_fw_of.c:94:6: error: use of bitwise '|' with boolean operands [-Werror,-Wbitwise-instead-of-logical]
        if (IS_ERR(pvsp->vreg.regctl) | IS_ERR(pvsp->vreg.regfw)) {
            ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                                      ||

../drivers/gpu/arm/mali/common/mali_executor.c:1380:42: error: a function declaration without a prototype is deprecated in all versions of C [-Werror,-Wstrict-prototypes]
static mali_bool mali_executor_is_working()
                                         ^
                                          void
```

加上编译环境变量 WERROR=0 还不够用，还要注释掉 drivers/media/platform/bst-a1000/Makefile 最后一行(cflags 相关)

> subdir-ccflags-y := -Wall -Werror

```
wuaoxiang@ubuntu:~/linux-rust$ file build/arch/arm64/boot/Image.itb
build/arch/arm64/boot/Image.itb: data
wuaoxiang@ubuntu:~/linux-rust$ cat /etc/os-release 
NAME="Ubuntu"
VERSION="20.04.4 LTS (Focal Fossa)"
```

但还是有一些漏网之鱼的警告，我最终改了根目录的 Makefile 中的 KBUILD_CFLAGS 去掉 -Wall 以及相应警告

### 禁用 MODVERSIONS 和 RANDSTRUCT 配置
一样的代码在 Ubuntu 22 上面这两个配置是禁用的所以 CONFIG_RUST 配置能出现，在 manjaro/archlinux 上面却启用了，这两都是自动的配置改不了导致无法启用 RUST

make xconfig 发现 MODVERSIONS 依赖 RANDSTRUCT

Google `linux disable RANDSTRUCT` 发现 clang 16+ 之后这个选项就被打开了，要加上一个 patch 才能禁用

<https://lore.kernel.org/lkml/CAKwvOdkYWXCYr75JkzHqMJ8j=UefW86Zq9tD_AyZQKzW__7TEA@mail.gmail.com/t/>

打上 patch 之后虽然 `grep RANDSTRUCT .config` 结果跟最新的 Linux 配置有差别，但 general_setup->rust_support 终于能看到了

#### RANDSTRUCT

```
RANDSTRUCT_FULL是Linux内核的一个配置选项，用于增强内核中数据结构的随机化。它是Linux内核中的一项安全功能，旨在增加系统的抗攻击能力，特别是针对内核数据结构的攻击。

当启用RANDSTRUCT_FULL时，内核会对一些关键的数据结构进行随机化，包括函数指针、结构体布局和其他内部数据。这种随机化使得攻击者更难以利用已知的数据结构布局和函数指针来进行攻击，从而增加了系统的安全性。

然而，需要注意的是，RANDSTRUCT_FULL选项会对内核的运行时性能产生一定的影响，因为它会引入一些额外的开销来进行随机化操作。因此，是否启用该选项需要在安全性和性能之间进行权衡考虑，根据具体需求进行配置。


如果一个配置项同时设置了 def_bool 和 depend_on，那么 depend_on 会具有更高的优先级
```

### 然而 clang 跟 bindgen 版本不一致会报错
bindgen 版本太高 Rust for Linux 代码太旧会报错

clang 版本太高，bindgen 版本太低也会报错

```
  RUSTC L rust/build_error.o
  RUSTC L rust/alloc.o
  EXPORTS rust/exports_alloc_generated.h
thread 'main' panicked at '"ftrace_branch_data_union_(anonymous_at__/_/include/linux/compiler_types_h_120_2)" is not a valid Ident', /home/w/.cargo/registry/src/rsproxy.cn-8f6827c7555bfaf8/proc-macro2-1.0.24/src/fallback.rs:693:9
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
make[1]: *** [rust/Makefile:329: rust/bindings/bindings_generated.rs] Error 1
make[1]: *** Deleting file 'rust/bindings/bindings_generated.rs'
make[1]: *** Waiting for unfinished jobs....
make: *** [Makefile:1286: prepare] Error 2
```

### 还是老实用 ubuntu Dockerfile



#### ubuntu 20.04 LLVM 版本设置成 11
系统默认版本是 10

```
  HOSTLD  scripts/kconfig/conf
***
*** Linker is too old.
***   Your LLD version:    10.0.0
***   Minimum LLD version: 11.0.0
***
scripts/Kconfig.include:56: Sorry, this linker is not supported.
make[3]: *** [../scripts/kconfig/Makefile:77: syncconfig] Error 1
```


```
#sudo ln -s /usr/bin/lld-11 /usr/bin/lld

ln -s /usr/bin/clang-11 /usr/bin/clang
ln -s /usr/bin/ld.lld-11 /usr/bin/ld.lld
ln -s /usr/bin/llvm-strip-11 /usr/bin/llvm-strip
ld.lld --version
```

---

## 不要 export ARCH=arm64 O=build
很玄学的是 export ARCH 环境变量之后会导致一堆头文件找不到的编译报错

`make ARCH=arm64 LLVM=1 WERROR=0 O=build -j$nproc` 就这样正常编译就行了

注意"环境变量"要写到make后面，如果写到make的前面的话效果就不一样了

## 不加 O=build 会出现一堆奇怪编译报错

```
  CC      security/selinux/ss/policydb.o
  CC      net/ipv4/protocol.o
In file included from drivers/bstn/bstn_sysfile.c:11:
In file included from drivers/bstn/bstn.h:78:
drivers/bstn/bstn_misc.h:19:10: error: 'bstn_netreg.h' file not found with <angled> include; use "quotes" instead
#include <bstn_netreg.h>
         ^~~~~~~~~~~~~~~
         "bstn_netreg.h"
1 error generated.
  CC      net/sched/act_api.o
make[3]: *** [scripts/Makefile.build:250: drivers/bstn/bstn_sysfile.o] Error 1
```

感觉像是黑芝麻的代码加到内核后配置写的不好的原因?问 gpt 不知道，问黑芝麻的人也没答复

## 内核镜像/驱动构建方法

最后生成引导镜像的命令是 mkimage -f ../kernel_a1000b.its arch/arm64/boot/Image.itb > /dev/null 2>&1

注意一定要使用 `arch/arm64/configs/bsta1000b_defconfig` 当默认配置

```
Command 'mkimage' not found, but can be installed with:
apt install u-boot-tools

# O=build would generate build/.config, not .config
make ARCH=arm64 LLVM=1 O=build bsta1000b_defconfig

# ubuntu 上编译不用加 WERROR=0
make ARCH=arm64 LLVM=1 O=build -j$nproc

# make modules_install 不会修改内核
make ARCH=arm64 LLVM=1 O=build INSTALL_MOD_PATH=modules_install INSTALL_MOD_STRIP=1 modules_install

# 看门狗驱动内嵌在内核中，似乎 NOC 要手动 insmod
tree build/modules_install/lib/modules/6.1.12+2-rt7/kernel/ | grep noc
│   │           └── bst_nocpmu.ko
```

!> 如果改了内核源码 git 版本不同，内核版本号末尾会多了个+ 例如 6.1.12+2-rt7+

nocpmu = network on chip performance monitor unit

```
modinfo build/modules_install/lib/modules/6.1.12+2-rt7/kernel/drivers/soc/bst/a1000/bst_nocpmu.ko
filename:       /home/w/repos/learningOS/linux-rust/build/modules_install/lib/modules/6.1.12+2-rt7/kernel/drivers/soc/bst/a1000/bst_nocpmu.ko
license:        GPL v2
author:         xy
description:    BST bst_nocpmu Driver
vermagic:       6.1.12+2-rt7 SMP mod_unload modversions aarch64RANDSTRUCT_98c7dcfed771a2f655b8fa6bdbcbd0ebaf8a0022c1f949cc21b93cf45ef2c351
name:           bst_nocpmu
intree:         Y
depends:        
alias:          of:N*T*Cbst,bst_noc_pmu
alias:          of:N*T*Cbst,bst_noc_pmuC*
srcversion:     C10B48FB0C49745087F8DCA
```

## clangd&ra

```
make ARCH=arm64 LLVM=1 O=build rust-analyzer
make[2]: *** No rule to make target 'rust-analyzer'.  Stop.

make ARCH=arm64 && make defconfig && make rust-analyzer
# 这时候会跳出配置选择框，因为之前编译的是 ARM 架构现在用 x86 就会提示跟 .config 配置不符合
# 弹出一堆对话框选择配置，这时候千万别选，选了就会改配置
```

关键是这个项目要 O=build 才能编译成功，冒然改配置在非build文件夹编译出一堆.o后，下次再O=build就会提示make mrproper 清空编译缓存重新编译太麻烦

bear + O=build 的编译倒是没有特别困难

```
make[1]: Entering directory '/home/wuaoxiang/linux-rust/build'
Traceback (most recent call last):
  File "../scripts/generate_rust_analyzer.py", line 141, in <module>
    main()
  File "../scripts/generate_rust_analyzer.py", line 134, in main
    "crates": generate_crates(args.srctree, args.objtree, args.sysroot_src),
  File "../scripts/generate_rust_analyzer.py", line 107, in generate_crates
    if f"{name}.o" not in open(path.parent / "Makefile").read():
FileNotFoundError: [Errno 2] No such file or directory: '../drivers/block/nvme_mq/Makefile'
make[2]: *** [../rust/Makefile:392: rust-analyzer] Error 1
make[1]: *** [/home/wuaoxiang/linux-rust/Makefile:1850: rust-analyzer] Error 2
```

touch drivers/block/nvme_mq/Makefile 就解决这个报错

## 一个内核模块报错
我搜索 drivers/soc 下面 module_init 找到 NOC 芯片的驱动代码? 的入口函数 

本来想打印一句话，结果编译报错，后来把 printk 放在第二行就没报错，后面我又移动到 return 0 的前面才解决报错

```diff
 int safety_netlink_init(void)
 {
-       pr_alert("Hello wuaoxiang's patch soc module");
        struct safety_msgdata kmsg;
+       pr_alert("Hello wuaoxiang's patch soc module");
```

---

## 上机调试

向日葵连 Ubuntu 上位机(密码root)，上位机连着黑芝麻 A1000 芯片域控制器盒子(以下简称)，USB0 是 a 核心 USB1 是 b 核心

```
minicom -b 115200 -D /dev/ttyUSB0

如果出现 "device /dev/ttyUSB0 is locked" 的错误消息
该串口设备已被其他程序（如另一个终端程序或串口监视工具）占用。在这种情况下，您需要先释放该设备的锁定，然后再次尝试使用minicom。可以尝试运行以下命令来释放设备：
Copysudo fuser -k /dev/ttyUSB0
minicom进程之前异常终止，但仍然保留了锁定文件。您可以手动删除锁定文件以解决这个问题。运行以下命令将锁定文件删除：
Copysudo rm /var/lock/LCK..ttyUSB0
完成上述步骤后，再次尝试运行minicom命令，应该可以成功连接到指定的串口设备。
```

虽然上位机跟A1000网络相连，A1000那边是个只有busybox的环境，所以靠scp传输文件是不可能的

串口通信minicom可以传输文件，reboot之后进入 A1000 系统用户root密码bsy2023

### 串口通信为什么不能传文件

串口传输速率慢，连接中的串口会当成终端用，即便用 minicom 发文件，文件内容会直接打印到终端上，导致 bash 报错 command not found 文件传输终止了

### adb 传输
在上次的 r4l 实验中，编译出的内核镜像文件大小在几十 MB，当然取决于架构、bootloader、内核裁剪、压缩方式等等因素

这次给的代码编译出的 Image.itb 只有 8M，有懂行的同学说内核裁剪出几百 KB 都是很常见的

这次实验嵌入式系统中更新内核代码是直接把内核镜像替换到 /dev/mmcblkxxx(SD card)

要如何将编译好的内核镜像传输到嵌入式系统呢，我们尝试了 串口,NFS,以太网 等等方式，最终老师说用 adb

### a/b 板?
有同学说实验环境有两个串口，正常开发板就一个串口，说明有两个板子

然后用 ifconfig/adb push 发现确实是两个系统两个不同文件系统两个不同IP

这时候有同学说，可能是汽车系统为了安全类似硬盘做冗余，两个板都是一样的功能，其中一个坏掉了另一个顶上

例如b板子内核恐慌看门狗也卡死了，a板子可以发信号重启b板子，但我网上找了些资料并无ab板子的资料

## adb push 传输文件
未执行 `mount /dev/mmcblk0p1 /mnt` 之前，adb push 文件到 /mnt 会看不到，push 到其他目录算正常，push 过来的文件像是被隐藏了

> /mnt命令来挂载文件系统，那么已存在的文件将会被隐藏起来，而不是被覆盖

### 系统卡死只能远程复位智能电源
嵌入式系统用的是米家一个智能电源可以在APP内远程复位电源解决操作系统卡死问题

### adb 能不能让b核板子重启？

|命令|报错|
|---|---|
|adb reboot|error: closed|
|adb install apk|cmd command not found|
|adb logcat|exec: logcat command not found|
|adb shell screencap|screencap command not found|

### USB 协议是个主从协议?
USB协议也支持一种特殊的模式，即On-The-Go（OTG）模式。在OTG模式下，一个设备可以既充当主机又充当从设备

上位机Ubuntu通过usb连接一个linux嵌入式系统，上位机通过adb进行文件通信，这个linux嵌入式系统是属于OTG模式

嵌入式系统可以在连接到Ubuntu主机时充当从设备，而在另外的情况下，如果需要与其他设备通信，它也可以充当主机

### 内核如何支持 adb
内核配置支持USB功能，并启用了ADB支持且设备上运行了 adbd 守护进程

---

## MTD=Memory Technology Device
为原始闪存设备（例如NAND，OneNAND，NOR 等）提供了一个抽象层。 这些不同类型的Flash都可以使用相同的API

## platform device

Linux源码学习之platform_driver

按照驱动probe用的结构体的不同去分类驱动
驱动可分为usb_serial_driver,platform_driver等等
基本上各种不同的驱动结构体都"继承"了device,device_driver

platform_driver适用于特定硬件平台
如图中所示树莓派的GPIO名字跟树莓派官网下载的dtb设备树文件中完全一致

```
[w@ww rpi_linux]$ git remote -v
origin	https://github.com/raspberrypi/linux.git (fetch)
origin	https://github.com/raspberrypi/linux.git (push)
[w@ww rpi_linux]$ dtc bcm2711-rpi-4-b.dtb -o rpi4.dtc 2>/dev/null
[w@ww rpi_linux]$ grep gpiomem rpi4.dtc
		gpiomem {
			compatible = "brcm,bcm2835-gpiomem";
[w@ww rpi_linux]$ grep -n -r "brcm,bcm2835-gpiomem" drivers/
drivers/char/broadcom/bcm2835-gpiomem.c:237:	{.compatible = "brcm,bcm2835-gpiomem",},
[w@ww rpi_linux]$ grep -B1 -A12 -n -H -h -r "brcm,bcm2835-gpiomem" drivers/
236-static const struct of_device_id bcm2835_gpiomem_of_match[] = {
237:	{.compatible = "brcm,bcm2835-gpiomem",},
238-	{ /* sentinel */ },
239-};
240-
241-MODULE_DEVICE_TABLE(of, bcm2835_gpiomem_of_match);
242-
243-static struct platform_driver bcm2835_gpiomem_driver = {
244-	.probe = bcm2835_gpiomem_probe,
245-	.remove = bcm2835_gpiomem_remove,
246-	.driver = {
247-		   .name = DRIVER_NAME,
248-		   .owner = THIS_MODULE,
249-		   .of_match_table = bcm2835_gpiomem_of_match,
```

## 

Linux源码学习之bindings_helpers

C函数签名带static的不会暴露在动态库/静态库的符号中，约等于"私有函数"

例如ioremap只好创建一个非static的rust_helper_ioremap函数当作wrapper把私有函数包一层
另外一种办法是static inline函数内一般都是调用一个公开的函数，要不就直接调里面的函数也行