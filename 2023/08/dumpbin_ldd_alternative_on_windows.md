# [dumpbin](/2023/08/dumpbin_ldd_alternative_on_windows.md)

`fatal error LNK1181: cannot open input file 'kernel32.lib'`

windows 上编译数据库驱动代码报错有两个库找不到 kernel32.lib 和 advapi32.lib

问了下 gpt 原来 .lib 后缀是 windows static lib 的意思

advapi32 类似 libcrypto.so，kerneli32.lib 需要安装 windows SDK

---

## visual developer prompt

dumpbin 是 Desktop development with C++ 组件，例如 clang/dumpbin 都要通过 vs 安装

但是安装之后不会加进 PATH 想用的时候，

通过 windows terminal 或 visual studio 打开一个 visual developer prompt 终端

再去 where clang 找到 clang 路径，例如我电脑上是 

> C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Tools\Llvm\bin

## dumpbin 还能显示用了动态库哪个函数

dumpbin /imports 输出示例

```
    api-ms-win-crt-string-l1-1-0.dll
             1402A94E0 Import Address Table
             140372BB0 Import Name Table
                     0 time date stamp
                     0 Index of first forwarder reference

                          68 isdigit
                          98 toupper
                          64 isalnum
                          6E isspace
                          86 strcmp
                          8E strncmp
                          84 strcat
                          8F strncpy
                          89 strcpy_s
                          85 strcat_s
                          88 strcpy
                          8B strlen
```
