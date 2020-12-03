# 嵌入式/no_std笔记

经验之谈，no_std编译成rlib给其它Rust程序调用例如`cargo test`是最简单了，

我参考了`lib-print`的源码自己实现println!也就20行，目前1.50版本stable的no_std仅支持编译到rlib

编译成DLL(.so)或SLL(.a)库文件，就要上nightly加很多内容

```rust
#![no_std]
#![feature(lang_items)]

#[no_mangle]
pub extern "C" fn add(lhs: i32, rhs: i32) -> i32 {
    lhs+rhs
}

#[lang = "eh_personality"]
extern "C" fn eh_personality() {}

#[panic_handler]
fn my_panic(_info: &core::panic::PanicInfo) -> ! {
    loop {}
}
```

如果更进一步，想要编译成executable，例如交叉编译到AVR处理器的arduino UNO，就变得极其困难

## no_std binary

.cargo/config.toml:

```toml
# or `cargo rustc -- -C link-arg=-nostartfiles`
[target.'cfg(target_os = "linux")']
rustflags = ["-C", "link-arg=-nostartfiles"]

# or `cargo rustc -- -C link-args="-e __start -static -nostartfiles"`
[target.'cfg(target_os = "macos")']
rustflags = ["-C", "link-args=-e __start -static -nostartfiles"]

[target.'cfg(target_os = "windows")']
rustflags = ["-C", "link-args=/ENTRY:_start /SUBSYSTEM:console"]
```

```rust
#![no_std]
#![no_main]
#![feature(lang_items)]

// entry_point/start_address of process, since the linker looks for a function named `_start` by default
#[no_mangle]
pub extern "C" fn _start() -> ! {
    loop {}
    // TODO impl process exit(1) in no_std
}

#[lang = "eh_personality"]
extern "C" fn eh_personality() {}

#[panic_handler]
fn my_panic(_info: &core::panic::PanicInfo) -> ! {
    loop {}
}
```

我查阅了以下资料勉强写出上述能编译通过的executable代码

- https://os.phil-opp.com/freestanding-rust-binary/
- https://fasterthanli.me/series/making-our-own-executable-packer/part-12

可见glibc本质上也是对汇编的`syscall`指令的封装

## 当前Rust嵌入式的坑

MMIO模型似乎还不完美，比如说内存是可以随机分发的，但是MMIO的地址是固定的，不能move/copy/drop，而且不能优化，，有时候volatile的操作还涉及event问题

嵌入式主要就GPIO、定时器、硬件通信接口、内存这几大块

Rust目前还没有明确的嵌入式内存模型，上层的HAL也是搞的太高大上走偏了(一帮搞软件的思路)
