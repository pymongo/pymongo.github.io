# [rustc guide 读书笔记 1](2021/11/rustc_dev_guide_1.md)

## 读书笔记覆盖范围

- about-this-guide
- getting-started

当前进度: how-to-build-and-run.html#create-a-configtoml

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
