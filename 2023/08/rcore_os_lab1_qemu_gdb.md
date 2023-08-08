# [rcore lab1 qemu gdb](/2023/08/rcore_os_lab1_qemu_gdb.md)

yay -S riscv-gnu-toolchain-bin

riscv64-unknown-elf-gdb: error while loading shared libraries: libpython3.8.so.1.0

从 ubuntu20.04 拷贝 libpython3.8.so 之后

> Fatal Python error: init_fs_encoding: failed to get the Python codec of the filesystem encoding
Python runtime state: core initialized

好吧还是从 https://github.com/riscv-collab/riscv-gnu-toolchain 源码安装

结果 make linux 卡在 `git clone submodule`... 所以 rcore 官方教程推荐下载 <https://static.dev.sifive.com/dev-tools/riscv64-unknown-elf-gcc-8.3.0-2020.04.1-x86_64-linux-ubuntu14.tar.gz>

---

## rcore 实验一

<http://rcore-os.cn/rCore-Tutorial-Book-v3/chapter1/4first-instruction-in-kernel2.html?highlight=strip%20all>

先掌握下作业题和实验代码的方法论，在操作系统训练营中

- 作业题通常是 github classroom 克隆一份代码仓库 make rustlings 解决完编译错误提交代码跑 CI 打分
- 实验题通常是克隆一个代码仓库，例如实验一就 git checkout ch1 最后 make run

由于 makefile 没有 `set -x` 我也不熟悉，我把 rcore 实验一的 makefile 代码整理成 shell 脚本

```sh
<<- EOF
[build]
target = "riscv64gc-unknown-none-elf"
[target.riscv64gc-unknown-none-elf]
rustflags = [
    "-Clink-arg=-Tsrc/linker.ld", "-Cforce-frame-pointers=yes"
]
EOF
cargo clean
cp src/linker-qemu.ld src/linker.ld
cargo b

# objcopy --only-section copy code/data section only?
target=target/riscv64gc-unknown-none-elf/debug
riscv64-unknown-elf-objcopy $target/os --strip-all -O binary $target/os.bin

qemu-system-riscv64 -machine virt -nographic \
    -bios ../bootloader/rustsbi-qemu.bin \
    -s -S \
    -device loader,file=$target/os.bin,addr=0x80200000
```

`-device` 告诉 qemu 帮忙将二进制镜像加载到内存指定位置

想着 gdb 能看点函数符号，我尝试去掉 --strip-all 结果 qemu 一运行就卡死了

我的思考是 0x802 内存地址必须紧凑排满生成出的代码块，因此就不能 debug symbol? 这里我没想明白，linux kernel 确实也有 debug symbol 相关配置

解答: rcore 书中有解释为什么用这个地址，看本文后续 ELF section 解释以及 linker-qemu.ld 源码中都是将各个 section 位置写死装载到内存中

## 为什么用 0x80200000 地址
qemu 源码内存布局写死的 0x80000000 是 DRAM 也就是内存的首地址

然后将 ROM 中的固件 RustSBI 加载到内存中占用了 200000 大小

## qemu gdb 初体验

> riscv64-unknown-elf-gdb -ex 'file target/riscv64gc-unknown-none-elf/debug/os' -ex 'set arch riscv:rv64' -ex 'target remote localhost:1234'

ubuntu 用 gdb-multiarch 亦可

用 `i r` 命令也就是 info registers 的缩写看看寄存器的值

`i r mstatus` 能看一些特殊寄存器

mstatus 跟 riscv 的模式有关，例如 User mode 跟 Machine mode 之间的切换就是通关修改 mstatus 寄存器实现的



结果全是 0 只有当前执行指令地址的 pc 寄存器有值 0x1000

```
(gdb) x/10x 0x1000
0x1000: 0x00000297      0x02828613      0xf1402573      0x0202b583
0x1010: 0x0182b283      0x00028067      0x80000000      0x00000000
0x1020: 0x87e00000      0x00000000
```

用 `x /10x 0x1000` 命令看内存地址 0x1000 开始，往后看 10 个 32bit，x 表示用 16 进制显示

由于 RustSBI 版本有所变动，所以这 10 个指令内容跟书中不一样很正常

## vscode gdb 看不到寄存器

毕竟内核代码是编译出来的 ELF 文件 strip 掉一堆元信息，vscode 调试窗口看不到变量值，估计 CLion 也是看不到

```json
{
    "name": "rcore-os",
    "type": "cppdbg",
    "request": "launch",
    "program": "${workspaceFolder}/os/target/riscv64gc-unknown-none-elf/debug/os",
    "args": [
        "-ex",
        "file target/riscv64gc-unknown-none-elf/debug/os",
        "-ex",
        "set arch riscv:rv64"
    ],
    "stopAtEntry": false,
    "cwd": "${workspaceFolder}",
    "environment": [],
    "externalConsole": false,
    "MIMode": "gdb",
    "setupCommands": [
        {
            "description": "",
            "text": "-enable-pretty-printing",
            "ignoreFailures": true
        }
    ],
    "miDebuggerPath": "/home/w/files/apps/riscv64_toolchain/bin/riscv64-unknown-elf-gdb",
    "miDebuggerServerAddress": "localhost:1234" 
}
```

## 常用工具使用方法笔记

http://rcore-os.cn/rCore-Tutorial-Book-v3/appendix-b/index.html#

### readelf/rust-readobj

readelf -h os/target/riscv64gc-unknown-none-elf/debug/os

```
ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00 
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           RISC-V
```

rust-readobj require cargo-binutils and rustup llvm-tools-preview component

rust-readobj -all os/target/riscv64gc-unknown-none-elf/debug/os | head

```
File: os/target/riscv64gc-unknown-none-elf/debug/os
Format: elf64-littleriscv
Arch: riscv64
AddressSize: 64bit
LoadName: <Not found>
ElfHeader {
  Ident {
    Magic: (7F 45 4C 46)
    Class: 64-bit (0x2)
```

Magic 前 4 byte 是固定组合让加载器快速确定文件是不是一个 ELF

text section 就是代码段一般在前两个位置 text section 的例子

```
  Section {
    Index: 1
    Name: .text (1)
    Type: SHT_PROGBITS (0x1)
    Flags [ (0x6)
      SHF_ALLOC (0x2)
      SHF_EXECINSTR (0x4)
    ]
    Address: 0x80200000
    Offset: 0x1000
    Size: 21684
```

当将程序加载到内存的时候，对于每个 program header 所指向的区域，我们需要将对应的数据从文件复制到内存中

!> 这也是为什么 cargo b 编译出 elf 必须 strip-all 去掉所有无关 section 才能让首个地址才是代码

由于实验一代码限定死了内存布局，只有 strip-all 才能让我们手动完成【加载】任务

说起 ELF 文件加载想起一本必须要看的经典书《程序员的自我修养：链接、装载与库》

### ELF 三个核心 section
- .text: 放代码和常量
- .bss:  未初始化的 static 变量
- .data: 已初始化的 static 变量
- .rodata: 已初始化只读的 static 变量
- .srodata: String-Read Only Data

## objdump 反汇编
rust-objdump -all target/riscv64gc-unknown-none-elf/release/os

可以去找下 main/_start 的汇编代码

## objcopy
实验一中已经用熟练了

---

## linker 原理
rcore 第一章好多内容都是 链接、装载与库 书中知识，再次觉得自己看的书太少了

linker 在汇编器后执行，算是编译的最后一步了

1. symbol resolution
2. symbol relocation
3. symbol merging
4. relocation table generate
5. generate executable file or dylib

### relocation
多个编译好的 .o 格式 ELF 文件，合并所有 ELF 文件的 .text,.data 等部分

因此合并前源文件中 函数符号到内存地址的映射 合并后会变化，需要 relocation 重新定位一遍

对于动态库的符号会存一个符号表，不会在 link 阶段映射出内存地址

### ld script 示例讲解

```
.rodata : {
    *(.rodata .rodata.*)
    *(.srodata .srodata.*)
}
```

首先 `*()` 是个通配符，也就是匹配所有 .o 文件中，带 .rodata 或者带 .rodata. 前缀的所有 section

### runtime linker/loader
ld.so 运行时将程序所需的动态库加载到内存(多个程序还是能复用同一个动态库内存)，并将程序动态库符号表 relocation

### linker-qemu.ld 源码
手动做 symbol merging 和 relocation 的步骤，手动去合并 .text 等 section

stext,etext 分别表示 start text 和 end text

`global_asm!(include_str!("entry.asm"));` 做了一些跟 sbi/qemu 之前初始化的工作，然后再跳转到 rust main 函数，因此 text 段先拼上了 .entry.start

### PIE，Position-independent Executable
gdb `x/10i $pc` 看内存上当前指令往后的 10 个指令是什么

rcore 程序中的寻址全都是基础地址 0x80200000 的【相对地址】，因此**加载**到内存任意位置都能执行，
相反如果有的程序寻址是固定的内存地址，则要求一个固定的内存布局

## entry.asm 代码解读

汇编 `.global` 表示全局函数

以下代码是初始化【创建栈空间】的代码

```
    .globl _start
_start:
    # la 是伪指令 load address of src symbol to dst register
    la sp, boot_stack_top
    call rust_main

...
# 如果发生爆栈，则新数据会覆盖掉内核的其他代码
boot_stack_lower_bound:
    .space 4096 * 16
    .globl boot_stack_top
boot_stack_top:
```

对应 linker-qemu.ld 和 Rust 代码 clear_bss() `#[link_section]`

```
.bss : {
    *(.bss.stack)
    sbss = .;
    *(.bss .bss.*)
    *(.sbss .sbss.*)
}
```
