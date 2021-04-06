# [no_std binary(static link)](/2021/03/statically_linked_executable.md)

作者: 吴翱翔@pymongo，原文: [no_std binary(static link)](https://pymongo.github.io/#/2021/03/statically_linked_executable.md)

用 mac/windows 的读者可以试试`gcc -nostdlib main.c`能不能编译通过，

如果连C语言的 no_std 可执行文件都编译不了，那 Rust 的 no_std 环境也不能编译可执行文件.

目前无论是C语言还是 Rust, 仅在 linux 系统下能编译 no_std 的可执行文件，用 mac 或 windows 系统的读者要装 linux 虚拟机才能学习 no_std

mac/windows 都能编译 no_std 的 library,但是 mac 运行 no_std 的 binary 会报错`illegal hardware instruction`

RustChinaConf 2020的[Rust, RISC-V和智能合约](https://www.bilibili.com/video/BV1Yy4y1e7zR?p=12)中展示了一个 Rust 最简单的 no_std 可执行文件

我私下问过该topic演讲嘉宾，为什么 PPT 上的 no_std 代码在 mac 上运行会报错`illegal hardware instruction`

嘉宾建议我在 linux 系统下运行，我换 linux 后果然就正常运行了

no_std 可执行文件意味着不能依赖操作系统的动态链接库，意味着可执行文件将是纯 statically_linked_executable

推荐这个 [Making our own executable packer](https://fasterthanli.me/series/making-our-own-executable-packer)(linux) 系列文章: 

在介绍Rust如何编译运行 no_std 的可执行文件之前，先看看汇编和 C/C++ 是如何编译 no_std 的可执行文件

## 汇编语言编译可执行文件

x86 汇编主要有两种语法，一是 Unix 的 AT&T syntax，另一个则是 windows 的 Intel syntax

由于 AT&T 有贝尔实验室，而 Unix 操作系统和 C 语言都是贝尔实验室发明的，所以 linux 的 gcc 和 as 都用 AT&T 汇编语法

如果想用 Intel 汇编语法可以用 llvm 或 nasm 工具

rustc 生成的汇编默认是 Intel 语法，可以传入 llvm 参数让 rustc 生成 AT&T 语法的汇编代码

> rustc --emit asm -C llvm-args=-x86-asm-syntax=att main.rs

以这个网站[GNU Assembler Examples](https://cs.lmu.edu/~ray/notes/gasexamples/)
介绍的第一段汇编代码为准

编译运行这段代码有两个方法:

> gcc -c s.s && ld s.o && ./a.out

或者用as工具(GNU assembler (GNU Binutils))

> as s.s && ld s.o && ./a.out

可以用 ldd 工具校验编译生成的可执行文件是不是 statically linked (没有引入任何动态链接库)

汇编的劣势在于代码跟硬件架构绑定，gcc 编译这段代码时加上`-m32`参数指定生成32位的可执行文件时就会报错

## C 编译 no_std 可执行文件

用`gcc -nostdlib`参数很容易生成无动态链接库的可执行文件

```
[w@w-manjaro temp]$ echo "int main(){return 0;}" > main.c && gcc -nostdlib main.c && ldd ./a.out
/usr/bin/ld: warning: cannot find entry symbol _start; defaulting to 0000000000001000
        statically linked
```

C 在 no_std 的环境下程序的入口函数名字不能是 main,要改成 _start

```
[w@w-manjaro temp]$ echo "int _start(){return 0;}" > main.c && gcc -nostdlib main.c && ldd ./a.out
        statically linked
```

当然也可以让 gcc 加上`-m32`参数生成32位的可执行文件

## Rust 编译 no_std 可执行文件

```rust
#![no_std]
#![no_main]
#![feature(lang_items,asm)]

/// entry_point/start_address of process, since the linker looks for a function named `_start` by default
#[no_mangle]
extern "C" fn _start() -> ! {
    exit(0); // macOS: illegal hardware instruction
}

fn exit(code: isize) -> ! {
    unsafe {
        asm!(
            "syscall",
            in("rax") 60, // exit
            in("rdi") code,
            options(noreturn)
        );
    }
}

#[lang = "eh_personality"]
extern "C" fn eh_personality() {}

#[panic_handler]
fn my_panic(_info: &core::panic::PanicInfo) -> ! {
    loop {}
}
```

源码在我[这个仓库](https://github.com/pymongo/no_std_binary/blob/main/main.rs)，linux 下的编译方法:

> rustc -C link-arg=-nostartfiles main.rs

或者将以下两行写到`.cargo/config.toml`中

```
[target.'cfg(target_os = "linux")']
rustflags = ["-C", "link-arg=-nostartfiles"]
```

---

## 总结

当前 Rust 的 no_std 生态仅在 linux 上比较完善，其它平台 no_std 环境只能编译成 C 的动态链接库(cdylib)，不能编译成可运行的可执行文件

Rust/C/C++ 在 no_std 环境下想要打印`Hello World`还得用汇编指令 syscall 系统调用，需要开发者对汇编语言和操作系统有一定的了解才能在 no_std 环境下开发
