# [insmod](/2022/07/insmod.md)

## insmod

尝试插入 rust_print.ko 内核模块到本机

```
[w@ww linux]$ file samples/rust/rust_print.ko 
samples/rust/rust_print.ko: ELF 64-bit LSB relocatable, x86-64, version 1 (SYSV), BuildID[sha1]=c6d9eeed3bbdf2b2c0460a0078c53bfcbbce5966, with debug_info, not strippe
[w@ww linux]$ modinfo samples/rust/rust_print.ko 
filename:       /home/w/repos/clone_repos/linux/samples/rust/rust_print.ko
author:         Rust for Linux Contributors
description:    Rust printing macros sample
license:        GPL
vermagic:       5.19.0-rc6+ SMP preempt mod_unload 
name:           rust_print
intree:         Y

[w@ww linux]$ sudo insmod samples/rust/rust_print.ko
insmod: ERROR: could not insert module samples/rust/rust_print.ko: Invalid module format
```

modinfo 看到是 5.19 beta 的内核版本，看来内核版本不一样的模块是没法用了

## modprobe 强行加载

<https://blog.csdn.net/ymangu666/article/details/22872439>

```
[w@ww linux]$ sudo modprobe --force-vermagic samples/rust/rust_print
modprobe: FATAL: Module samples/rust/rust_print not found in directory /lib/modules/5.10.131-1-MANJARO

# NOTE 需要将 ko 文件拷贝到 /lib/modules/5.10.131-1-MANJARO 才能被 modprobe 认得

[w@ww linux]$ sudo cp samples/rust/rust_print.ko /lib/modules/5.10.131-1-MANJARO/
[w@ww linux]$ sudo modprobe --force-vermagic rust_print
modprobe: FATAL: Module rust_print not found in directory /lib/modules/5.10.131-1-MANJARO

# NOTE /lib/models/$(uname -r) 的模块文件需要 depmod -a 生成 .dep 依赖信息文件才能被 modprobe

[w@ww linux]$ depmod rust_print
depmod: ERROR: Bad version passed rust_print
[w@ww linux]$ sudo depmod -a

# NOTE 我机器内核模块库没有 Rust 函数符号信息，即便绕过内核版本限制还是用不了

[w@ww linux]$ sudo modprobe --force-vermagic rust_print
modprobe: ERROR: could not insert 'rust_print': Unknown symbol in module, or unknown parameter (see dmesg)
[w@ww linux]$ sudo dmesg -T | tail
[Wed Jul 20 10:56:08 2022] rust_print: Unknown symbol _RNvNtNtCsfATHBUcknU9_6kernel5print14format_strings6NOTICE (err -2)
[Wed Jul 20 10:56:08 2022] rust_print: Unknown symbol _RNvNtCsfATHBUcknU9_6kernel5print16call_printk_cont (err -2)
```

## 看自己内核没启用 rust

> zcat /proc/config.gz | grep CONFIG_RUST

好吧，放弃了，Rust-for-Linux 编译的内核装不了，只能开 qemu 虚拟机去跑

---

等下？能不能像 C 语言编译时引用 /lib/modules/$(uname -r) 我自己内核模块的文件，那应该是下一篇文章要介绍的内容了
