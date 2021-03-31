# [不依赖库不懂算法实现随机数生成](/2021/03/rand_ffi_binding.md)

如何不依赖任何第三方库、不懂任何算法的去实现一个类似Rust的rand::random()生成随机数的函数?

首先就不要重复造轮子了，看看随机数生成有那些现有的解决方案，很快我就想起C语言stdlib.h中有rand()这个函数

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

