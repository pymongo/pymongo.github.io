# [不依赖库不懂算法实现随机数生成](/2021/03/rand_ffi_binding.md)

如何不依赖任何第三方库、不懂任何算法的去实现一个类似 Rust 的 rand::random() 生成随机数的函数?

首先就不要重复造轮子了，看看随机数生成有那些现有的解决方案，很快我就想起 C 语言 stdlib.h 中有 rand() 这个函数

## 动态链接库

以下是一个最简单的Rust编译生成的可执行文件中引用的动态链接库

```
[w@w-manjaro temp]$ echo "fn main(){}" > main.rs && rustc main.rs && ldd ./main
        linux-vdso.so.1 (0x00007ffe4fbe1000)
        libgcc_s.so.1 => /usr/lib/libgcc_s.so.1 (0x00007fab10811000)
        libpthread.so.0 => /usr/lib/libpthread.so.0 (0x00007fab107f0000)
        libdl.so.2 => /usr/lib/libdl.so.2 (0x00007fab107e9000)
        libc.so.6 => /usr/lib/libc.so.6 (0x00007fab1061c000)
        /lib64/ld-linux-x86-64.so.2 => /usr/lib64/ld-linux-x86-64.so.2 (0x00007fab1089d000)
```

再看看gcc生成的一个最简单的可执行文件中引用的动态链接库

```
[w@w-manjaro temp]$ echo "int main(){return 0;}" > main.c && gcc main.c && ldd ./a.out
        linux-vdso.so.1 (0x00007ffeed086000)
        libc.so.6 => /usr/lib/libc.so.6 (0x00007f7b00a21000)
        /lib64/ld-linux-x86-64.so.2 => /usr/lib64/ld-linux-x86-64.so.2 (0x00007f7b00c21000)
```

可以发现 Rust 和 C 的可执行文件都引入了 libc.so.6 这个动态链接库，Rust libc 库的命名正是源自这个库

所以 Rust 是可以直接调用 C 的标准库，通常一个动态链接库 so 文件会对应多个头文件，

例如 stdio.h, time.h, stdlib.h 等等这些都是 libc.so 的函数定义

根据[rand 文档](https://www.cplusplus.com/reference/cstdlib/rand/)的函数定义很容易写出其 FFI 绑定的代码

```rust
#[link(name="c", kind="dylib")]
extern "C" {
    /// https://www.cplusplus.com/reference/cstdlib/rand/
    fn rand() -> i32;
}
```

`#[link(name="c", kind="dylib")]`这行虽然可以不写，但是写上能更清晰的知道每个函数是源自哪一个动态链接库

C 语言里动态链接库的命名规则是 lib + $name + .so，所以`libc.so.6`的名字是`c`

将 C 语言的 rand 函数包一层很容易写出我们自己的第一个版本的随机数函数:

```rust
fn random() -> i32 {
    #[link(name="c", kind="dylib")]
    extern "C" {
        /// https://www.cplusplus.com/reference/cstdlib/rand/
        fn rand() -> i32;
    }

    unsafe {
        rand()
    }
}
```

但是 rand 如果不初始化一个随机数的种子(seed)，则生成的随机数的随机性不高，很可能连续两次调用都返回同一个数字

## time and srand

业界普遍做法是调用 rand 之前，给 srand 传入当前时间戳作为随机数生成器的种子

函数 time() 的定义是`fn time(arg: *mut time_t) -> time_t;`，根据 libc 源码 time_t 是 i64 类型

所以可以有两种调用方法

一种是 Rust 先定义一个可变 i64 变量，再将其指针传入 time()，让C语言把时间戳赋值给该变量

另一种则是 Rust 传入一个空指针，然后拿一个变量去接住 time() 的返回值

