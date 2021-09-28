## coding abbreviation

- cb -> callback, 常见于网络编程例如 read_cb/listen_cb，参考源码 repo: rust-reactor-executor-example, rust-epoll-example 
- tx -> transaction, 常见于 sqlx 的源码和 channel 的发送/接收端命名
- srv -> server
- conn -> connection
- ret -> return_value, 常见于 leetcode 题解，题解的返回值的变量名通常都用 ret 或 ans，用 res 容易和 Rust 的 Result 产生歧义
- _ext suffix: ext=extension, 例如futures_ext crate，例如B和C结构体"继承"了A，而且B和C在A的字段基础上多了一些字段，此时可以将B和C命名为A的a_ext
- COMM -> command, 例如I2C通信协议的命令COMMAND: TM1637_I2C_COMM1

## distributed database abbreviation

- WAL: Work Ahead Log
- HA: High Availability
- HTAP: Hybrid Transactional/Analytical Processing
- OLTP: 线上请求(Online Transactional Processing)
- OLAP: 后台分析(Online Analytical Processing)
- POC: Push-to-Talk over Cellular
- MVCC: Multi Version Concurrency Control

- elasticity: 弹性
- data_inconsistency: 数据不一致性
- data are scattered in various files: 数据分散在多个文件

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
- MSRV(minimum supported Rust version): https://github.com/rust-lang/rust-clippy/blob/master/doc/adding_lints.md


## 互联网公司术语缩写

- SAW: Security Access Workstation 公司内只有这种电脑能访问生产环境
- BI: Business Intelligence(例如神策公司的产品)

## misc

v.s.: versus
