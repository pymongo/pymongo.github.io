## coding abbreviation

- tx -> transaction, 常见于sqlx的源码
- srv -> server
- conn -> connection
- ret -> return_value, 常见于leetcode题解，题解的返回值的变量名通常都用ret或ans，用res容易和Rust的Result产生歧义
- _ext suffix: ext=extension, 例如futures_ext crate，例如B和C结构体"继承"了A，而且B和C在A的字段基础上多了一些字段，此时可以将B和C命名为A的a_ext
- COMM -> command, 例如I2C通信协议的命令COMMAND: TM1637_I2C_COMM1

### _opt suffix

opt=Option, usually use in function_indentation means the output of function_name is a Option.

Example: chrono::NaiveDateTime::from_timestamp_opt 

## 英文技术社区(github/reddit)常见英文口语缩写

- feat: feature
- AKA: Also Known As
- FYI: For Your Information
- AFAICT: As Far As I Can Tell
- LGTM: An acronym(首字母缩写) for "Looks Good To Me"
- In a nutshell(简而言之)
- TLDR: Too Long Didn't Read
- wip: working in progress
- CVE: Common Vulnerabilities and Exposures

## Rust的PR/issue常见缩写

- MIR/HIR: LLVM中间语言，Rust编译过程简单来说从AST到High-Level IR再到MIR再到LLVM IR(Intermediate Representation)
- GAT: generic associated types
- ICE(Internal Compiler Errors): rustc编译器内部出错
- MMU(Memory Manage Unit)
- OOM(Out Of Memory): <https://github.com/rust-lang/rust/pull/84266>

## 互联网公司术语缩写

- SAW: Security Access Workstation 公司内只有这种电脑能访问生产环境
- BI: Business Intelligence(例如神策公司的产品)
