## data warehouse term
- SQL Lineage Analysis: SQL 血缘分析()

## coding abbreviation

- cb -> callback, 常见于网络编程例如 read_cb/listen_cb，参考源码 repo: rust-reactor-executor-example, rust-epoll-example 
- tx -> transaction, 常见于 sqlx 的源码和 channel 的发送/接收端命名
- srv -> server
- svc -> service
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
- POC: Proof of Concept，简单来说就是产品竞标打分，是业界流行的针对客户具体应用的验证性测试
- MVCC: Multi Version Concurrency Control
- DAG: directed acyclic graph 有向无环图
- ETL: Extract,Transfer,Load 指定是数仓或者数据库人员对业务数据进行抽象建模设计数据库表字段的工作
- DAU: Daily Active User 日活跃用户
- RBO: rule base optimization (第一种是基于规则的优化器)
- CBO: cost base optimization (cost model 第二种是基于代价的优化器)

- RDD: Resilient Distributed Dataset, spark 的分布式计算模型

- backfill: 当你错过了某一次执行时间之后，往回去补充执行的行为
- elasticity: 弹性
- compaction: 压缩
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

## Rust 社区常见术语或缩写

- MIR/HIR: LLVM中间语言，Rust编译过程简单来说从AST到High-Level IR再到MIR再到LLVM IR(Intermediate Representation)
- GAT: generic associated types
- ICE(Internal Compiler Errors): rustc编译器内部出错
- MMU(Memory Manage Unit)
- OOM(Out Of Memory): <https://github.com/rust-lang/rust/pull/84266>
- MSRV(minimum supported Rust version): https://github.com/rust-lang/rust-clippy/blob/master/doc/adding_lints.md
- SSA(Solidty Static Analysis?): rustc_codegen_ssa, 所有的 codegen 都要引入 codegen_ssa


## 互联网公司术语缩写

- SAW: Security Access Workstation 公司内只有这种电脑能访问生产环境
- BI: Business Intelligence

## Java

- failover: 当 master 挂掉以后, 能选出一个 slave 晋升成 Master 继续提供服务
- Actuator

## misc

- v.s.: versus
- clang地址消毒(Address Sanitizer)检查内存错误

---

## term in naming

- query 和 search: query 用于结构化数据查询，能快速得到结果，例如数据库；search 则偏非结构/模糊查询，例如 google search
- state 和 status
都表示状态，但是有状态转移的用 state 无状态转移的用 status 例如 HTTP status code
<https://liqiang.io/post/status-or-state-fa70399e>

---

## term in microservice

- SOA: Service-Oriented Architecture
- Service Mesh: 服务网格如 lstio

§ 不可变基础设施:  
不再局限于方便运维、程序升级和部署的手段，而是升华为向应用代码隐藏分布式架构复杂度

§ 蓝绿部署:  
蓝当前版本且有业务流量，绿新版本代码，同一时间业务流量只会重定向到蓝或绿，一旦新版本出问题可以立即将流量重定向回旧版本

§ 灰度发布/金丝雀发布:  
跟蓝绿类似两套环境，不同的是先是 1% 流量导流到新环境，然后没问题的话慢慢提高到 10%, 25%, 100%。
这样新代码环境出了问题也只会影响极小部分用户，所以也能先让 1/3 机器升级版本再慢慢测试让业务流量一点点的导流到部署新版本的机器上

