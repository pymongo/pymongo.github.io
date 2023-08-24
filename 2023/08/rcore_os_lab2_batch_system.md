# [lab2 批处理系统](/2023/08/rcore_os_lab2_batch_system.md)

## qemu-riscv64
从本实验开始会同时写用户态应用和操作系统软件

qemu-riscv64 和 qemu-system-riscv64 的区别是 前者在 riscv64 Linux 上面跑应用 而后者则是跑操作系统

测试应用代码之前我们可以用 qemu-riscv64 直接跑应用代码更加方便

注意 rcore 实验的代码搭配的 RustSBI 强行绑定 qemu7.0 的内存布局以及相应 link script

因此用 qemu 8.0 去跑 hello 应用打印完就直接 SIGSEGV，评论区说用 qemu7.2 跑也是 coredump

没办法为了教学我尝试编译 qemu7.0 源码结果 `error: redefinition of ‘struct file_clone_range’` 网上查了下原来是 glibc 2.36 才会出现的报错，看来我 archlinux 是没法编译低版本了

然后 qemu 的 image 只有 naive 版本没有 riscv...

评论区有人说用编译器默认的 linker 的内存布局就能跑了，果然我去掉 clear_bss() 以及 .cargo/config.toml 的 ld 配置跑 qemu-riscv64 就没有段错误了，而且不需要 objcopy --strip-all 果然有操作系统帮忙加载到内存就简单不少了

## 从零写 riscv64 应用

cargo new/init 后 `[build]\ntarget = "riscv64gc-unknown-none-elf"` 加到 .cargo/config.toml

### can't find crate for `std`
要给所有的 lib 和 bin target 加上 `#![no_std]`

rustup list 并不能查询某个 target 支持什么 component

只能去 rustup-components-history 网站查询 <https://rust-lang.github.io/rustup-components-history/wasm32-unknown-unknown.html>

例如几年前我刚学 no_std 的时候 wasm 还不支持 rust-std 组件，没想到 2023 年之后 wasm 也能用 std 了

好吧这个查询方法好不准啊，riscv 和 wasm 都显示有 rust-std 结果其实就 wasm 有

好吧最靠谱的办法还是编译器检查，反正 std 组件是必装的，如果调用 std 报错那说明当前 target no_std

### ra 误报 can't find crate for test

.vscode/settings.json 加两行配置

```
"rust-analyzer.cargo.target": "riscv64gc-unknown-none-elf",
"rust-analyzer.checkOnSave.allTargets": false,
```

### wasmer Missing export _start
```
error: The module doesn't contain a "_start" function. Either implement it or specify an entrypoint function.
╰─▶ 1: Missing export _start
```

换上 no_main 之后运行时也没有打印，说明 wasm 所谓的 std 其实还是有一定局限性

```rust
#![no_main]
#[no_mangle]
fn _start() {
    println!("foo");
}
```

### vscode task

```json
{
    "label": "run",
    "type": "shell",
    // `qemu-riscv64 2>&1` redirect stderr to stdout because vscode doesn't capture task output
    "command": "cargo b --bin $binary && qemu-riscv64 2>&1 target/riscv64gc-unknown-none-elf/debug/$binary",
    "options": {
        "env": {
            "binary": "panic"
        }
    },
}
```

### 没有 exit 会 coredump
我尝试写个空的 main 函数，结果一跑就 coredump

```rust
pub fn syscall(id: usize, args: [usize; 3]) -> isize {
    let mut ret: isize;
    unsafe {
        core::arch::asm!(
            "ecall",
            // a0 function argument or return value register
            // inlateout means use reg input and later receive output
            inlateout("x10") args[0] => ret,
            // a1 function argument or return value register
            in("x11") args[1],
            // a2
            in("x12") args[2],
            // a7
            in("x17") id
        );
    }
    ret
}

const SYSCALL_WRITE: usize = 64;
const SYSCALL_EXIT: usize = 93;

pub fn exit(exit_code: i32) {
    syscall(SYSCALL_EXIT, [exit_code as usize, 0, 0]);
}

// rcore lab1 use sbi::put_char to print
pub fn print<T: AsRef<[u8]>>(buf: T) {
    let buf = buf.as_ref();
    let fd = 1i32;
    syscall(
        SYSCALL_WRITE,
        [fd as usize, buf.as_ptr() as usize, buf.len()],
    );
}
```

### qemu 调 sbi::console_putchar 失败

要想打印字符串，除了用 write 系统调用我还想到 sbi putchar

```rust
#[no_mangle]
fn _start() -> ! {
    const SBI_CONSOLE_PUTCHAR: usize = 1;
    // nothing happen
    qemu_riscv64_apps::syscall(SBI_CONSOLE_PUTCHAR, 'h' as usize, 0, 0);
    qemu_riscv64_apps::syscall(SBI_CONSOLE_PUTCHAR, '\n' as usize, 0, 0);

    qemu_riscv64_apps::print("haha\n");
    qemu_riscv64_apps::exit(0);
    panic!("unreachable");
}
```

毕竟 qemu-riscv64 底下不是 RustSBI 所以 SBI_CONSOLE_PUTCHAR 什么都没发生

### 尝试越级执行 wfi 指令

> 2877394 Illegal instruction     (core dumped)

### dbg! 实现

```rust
/// copy from https://github.com/rust-lang/rust/blob/1.71.0/library/std/src/macros.rs#L340-L362
#[macro_export]
macro_rules! dbg {
    // NOTE: We cannot use `concat!` to make a static string as a format argument
    // of `eprintln!` because `file!` could contain a `{` or
    // `$val` expression could be a block (`{ .. }`), in which case the `eprintln!`
    // will be malformed.
    () => {
        println!("[{}:{}]", file!(), line!())
    };
    ($val:expr $(,)?) => {
        // Use of `match` here is intentional because it affects the lifetimes
        // of temporaries - https://stackoverflow.com/a/48732525/1063961
        match $val {
            tmp => {
                println!("[{}:{}] {} = {:#?}",
                    file!(), line!(), stringify!($val), &tmp);
                tmp
            }
        }
    };
    ($($val:expr),+ $(,)?) => {
        ($($crate::dbg!($val)),+,)
    };
}
```

---

## 为什么设计了内核栈
隔离开用户进程的栈，安全性，现在的计算机性能反正都过剩了，牺牲点空间性能换取安全性

还有一个作用就是内核栈存储了 trap context 包含了应用程序的寄存器数值

> 首先将 sscratch 的值读到寄存器 t2 并保存到内核栈上，注意： sscratch 的值是进入 Trap 之前的 sp 的值，指向用户栈。而现在的 sp 则指向内核栈。

> 我们不能直接使用这些寄存器现在的值，因为它们可能已经被修改了，因此要去内核栈上找已经被保存下来的值

最后内核 trap 处理完之后调用 __restore 将内核栈保存下来的寄存器值(上下文)写回到寄存器中

## sys_write 越界检查编程题

```rust
if ptr < APP_BASE_ADDRESS {
    return -1;
}
if ptr + len > APP_BASE_ADDRESS + APP_SIZE_LIMIT {
    return -1;
}
```

就这两个 if 判断就完活了，有点偷鸡摸狗

---

(lab2 好多中断寄存器修改指令代码看的好痛苦记不住)

---

lab2/lab3 参考代码? <https://github.com/jackming2271/rCore-Tutorial-v3/tree/ch3>

<https://github.com/Create-a-Second-Earth-2030/reimplement-rCore-Tutorial-v3-from-scratch>
