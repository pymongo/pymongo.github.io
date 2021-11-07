# [rustc guide 读书笔记 1](2021/11/rustc_dev_guide_1.md)

## 读书笔记覆盖范围

- about-this-guide
- getting-started

当前进度: suggested.html#installing-a-pre-commit-hook

## bootstrapping

可以大致看看 [compiler team experts map](https://github.com/rust-lang/compiler-team/blob/master/content/experts/map.toml) 里面将 rustc 分成哪些领域知识

rustc is a bootstrapping compiler // 此处的 bootstrapping 的意思是自举(用 Rust 编译 rustc 编译器)

## x.py

一般 x.py setup 只选 a 和 b 编译到 stage1 即可

```
$ x.py setup
Welcome to the Rust project! What do you want to do with x.py?
a) Contribute to the standard library
b) Contribute to the compiler
```

`x.py build` 的 `--keep-stage 1` 参数似乎没啥用也没加快编译

```
# First build
./x.py test src/test/ui

# Subsequent builds, --bless option means update current stdout/stderr to ui test file
./x.py test src/test/ui --keep-stage 1 --bless
```

## glossary

### FCP

FCP = Final Comment Period: 一般不兼容改动需要多个团队的大部分成员一起开会讨论，且需要 crater run 扫描 crates.io 的所以库并量化影响范围

used in breaking change or features gate

### MCP

MCP = Major Change Proposal

## 默认的 stage1 编译过程

Unfortunately, incremental cannot be used to speed up making the stage1 libraries

1. Build std using the stage0 compiler (using incremental)
2. Build stage1.rustc using the stage0 compiler (using incremental)
3. Build stage1.std using the stage1 compiler (cannot use incremental)

## suggested.html#configuring-rust-analyzer-for-rustc

重要的必做内容， vscode 和 ra 设置上 x.py check 之后 ra 可以在 Rust 源码仓库进行代码跳转的类型提示
