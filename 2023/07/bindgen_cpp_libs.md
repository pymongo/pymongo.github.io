# [bindgen cpp libs](/2023/07/bindgen_cpp_libs.md)

因国产化业务需求，显卡换成摩尔线程，数据库也得从 pg 换成航天天域数据库，因业务代码以 sqlx 为主我尝试通过该国产数据库的 C 动态库开发一个 sqlx 的 driver

首先就必须先把头文件 codegen 生成出 Rust 代码我选用了官方的 bindgen 没用 cxx

## vscode clangd include

装了 clangd 之后 demo.cpp 源码依然一堆 undefined

gpt 这个抖机灵说可以在 vscode 配置加个

```
{
    "clangd.arguments": [
        "-I",
        "/path/to/include"
    ]
}
```

结果报错 `clangd: Unknown command line argument '-I'`

应该用 [vscode clangd.fallbackFlags](https://stackoverflow.com/questions/61206703/is-there-includepath-option-in-clangd)

或者 clangd 配置文件

```
CompileFlags:
  Add: 
    - "-I./path/to/include"
```

## bindgen include path

由于库文件的多个 .h 之间好多都是用尖括号互相引用导致出现以下报错

`error: 'xxx.h' file not found with <angled> include`

给 bindgen 的 clang_args() 传入 `-I./path/to/include` 即可解决

## clang -x c++

以下这两个报错很明显就是 .h 文件用了 C++ 语法，根据 bindgen 文档 clang 参数加上 -x c++ 即可解决

```
error: unknown type name 'class'
error: must use 'struct' tag to refer to type
```

## bindgen 工作原理

源码 `fn dump_preprocessed_input`

```rust
cmd.arg("-save-temps")
    .arg("-E")
    .arg("-C")
    .arg("-c")

if is_cpp {
    "__bindgen.ii"
} else {
    "__bindgen.i"
}
```

这堆 clang 参数其实就保留中间文件保留宏预处理后的文件

但 dump_preprocessed_input 是个 optional 选项，看来 codegen 核心逻辑不在这

核心代码在 bindgen/ir/context.rs 分别是 BindgenContext::new 和 BindgenContext::gen

用 clang_sys::clang_parseTranslationUnit 将头文件转换成 AST

最后将 C++ AST 转为 bindgen IR 进而生成出 Rust code

## 重复的 const

由于我是一次性将文件夹十几个头文件合并生成出一个 .rs 文件难免出现重复的 #define 翻译成 const 之后多个命名重复

看了下 bindgen 源码有用 vistor/counter 努力避免输出别重复，所以重复的 const 暂且只能手动删掉

其实我 bindgen 思路就错了不应该把 include 文件夹的每个 .h 都扔进去，找一个汇总的头文件即可

例如我 bindgen 这个库有个汇总的中心化的文件有定义 `#pragma once` 说明只预编译一次且里面引用了全部头文件说明就用这一个头文件够了

---

由于对方给了一个 main.cpp 的使用例子，于是我想能不能用 bindgen 也转换成 cpp 结果并不能 main 函数生成出来变成

```c
extern "C" {
    pub fn main() -> ::std::os::raw::c_int;
}
```
