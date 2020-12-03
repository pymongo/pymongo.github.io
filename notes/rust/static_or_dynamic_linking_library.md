# rustc和gcc之间互调DLL/SLL库

!> 以前觉得C语言调第三方库难，是因为根本就不懂gcc编译时如何引入SLL和DLL

学完gcc/rustc/build.rs引入DLL/SLL之后，不仅能在Rust代码里引入C语言的wiringpi库，还能学会gcc/Makefile如何构建多个第三方库的项目

自从我mac升级Big Sur系统后的Xcode变化导致我抄《Rust编程之道》的cc库编译C++代码给Rust调用的示例报错了(ld错误)

于是我萌生脱离cc/gcc这样的Rust库去实现Rust调用C++函数，但是这需要了解很多gcc工具链的背景知识

本文的参考资料: 

- [Static and Dynamic Library in C using gcc on Linux](https://medium.com/@adib.grouz/static-and-dynamic-library-in-c-using-gcc-on-linux-354edc5d88d3)

## object file

object_file = executable/dynamic_linking_library/static_linking_library?

object_file分三类: executable, relocatable(.o), shared(.so)

```
libarithmetic.a: current ar archive
add.o: ELF 32-bit LSB relocatable, ARM, EABI5 version 1 (SYSV), not stripped
libarithmetic.so:
    readelf -l: Elf file type is DYN (Shared object file)
    file: ELF 32-bit LSB pie executable
executable:
    readelf -l: Elf file type is EXEC (Executable file)
    file: executable, interpreter /lib/ld-linux-armhf.so.3
```

## tools for object files

- file: 简单的看看这是个什么类型的文件
- objdump: read object_files info or disassemble object_files
- ldd【重要排错工具】: 查看可执行文件依赖的so文件的路径
- readelf: 查看object_files的header信息
- nm: read object_files symbol info
- cpp: cpp main.c > main.i 能expand macros and headers file
- as: 将`cpp c.c > c.i && gcc -S c.i`生成的c.s文件`as c.s -o c.o`继续生成为.o文件，再通过很长的ld命令将.o生成为可执行文件
- ld: linker, 现在的gcc都比较方便自动链接，不用去敲[像文章里很长的ld命令](https://cs-fundamentals.com/c-programming/how-to-compile-c-program-using-gcc.php#Linking)
- ar: pack multi .o file to single .a SLL file 

### objdump disassemble

Display assembler contents of all sections 

> objdump -D executable

## gcc/g++ args

### -Wall

`-Wall` -W means warning, all means show all warnings, usually use in dynamic linking

### -fPIC

`-fPIC` -f means flag, PIC=Position Independent Code

`gcc -Wall -fPIC -c add.c` would generate a dynamic linking object files add.o

### -shared

生成DLL so文件用的

### -fPIC

!> DLL=Dynamic Linking Library

DLL use pic(position independent code) flag, but will have platform-dependent limitations

---

## linking

Linux/Mac: "lib{lib_name}.a" and "lib{lib_name}.so", Windows: .lib and .dll

SLL(*.a) and DLL/shared_libraries(*.so) is a collection of object files

动态链接和静态链接是编译成单个可执行文件的过程中，两种combining/collecting multiple object files的方式。

正是因为linker让开发single executable的代码/模块能实现解耦成多个动态/静态链接库，

例如当database module的代码改变时，只需要recompile and re-link database module to executable/application，

改了哪个动态静态链接库就recompile and re-link改动的库，而不需要重新编译所有源文件，而且每个动态静态链接库还能单独编译/测试 

!> 纯粹的statically_linked_executable仅能通过编译汇编代码来生成，glibc是对汇编syscall指令的封装

动态链接和静态链接是编译成单个可执行文件的过程中，两种combining/collecting multiple object files的方式。

### asm statically_linked_executable

```asm
;x86_64-linux
;nasm -f elf64 statically_linked_executable.s
;ld statically_linked_executable.o -o statically_linked_executable
;./statically_linked_executable
global _start

section .text
_start:
    mov rdi, 1   ; stdout fd
    mov rsi, msg
    mov rdx, 9   ; 8 chars + newline
    mov rax, 1   ; write syscall
    syscall

    xor rdi, rdi ; return code 0
    mov rax, 60  ; exit syscall
    syscall

section .data
msg:
    db "hi there", 10 ; "hi there\n", b'\n'=10u8
```

### DLL(Dynamic Linking Library)

DLL=Dynamic Linking Library=Shared Libraries

```
+ 在内存中只会存在一份DLL的拷贝，高效利用内存，多个可执行文件引入同一个DLL库也不会像静态库那样每个调用者都要复制一份造成内存浪费
+ 可以实现进程间资源共享和通信
+ 程序升级变得简单，修改DLL不需要重新编译依赖它的可执行文件
- 失去部分编译时静态分析的能力，像Rust将一些编译时的工作扔给运行时的API(RefCell,OnceCell)就没法享受Rust严格的编译期分析
```

### SLL(Static Linking Library)

```
+ 方便移植，可以让可执行在运行时不依赖操作系统的函数库(例如openssl)
- 可执行文件体积较大，不适合多个可执行文件共用一个库的场景(特别浪费内存/硬盘)
  例如Linux的系统调用ABI glibc就是一个.so，所以用file命令看Rust/C/C++编译后的可执行文件都含有dynamic link信息
```

## Rust和C互调SLL或SLL

代码示例: https://github.com/pymongo/learn_gcc
