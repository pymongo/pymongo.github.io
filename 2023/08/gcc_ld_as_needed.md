# [gcc/ld --as-needed](/2023/08/gcc_ld_as_needed.md)

在 archlinux 能编译的代码在 ubuntu20.04 上编译报错一个业务的动态库 undefined symbol

我很纳闷之前还能编译的是不是有同事改了 gcc 配置之类的，于是我让 gpt `how to print gcc linked so file when compile`

gpt 让我加上 `-Wl,--no-as-needed` 参数之后居然误打误撞就能编译过了

--no-as-needed option is used to prevent the linker from discarding unused shared object files
