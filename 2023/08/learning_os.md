# [learningOS](/2023/08/learning_os.md)

[国家智能网联的训练营/夏令营](https://mp.weixin.qq.com/s/yKHV40znJYoZBETf7D3MpA)课程是根据清华操作系统课程改编过来的

- <https://github.com/learningOS>
- <https://github.com/LearningOS/rust-based-os-comp2023/blob/main/relatedinfo.md>

## 学习进度
- CSAPP: ch1
- computer... RISC-V edition: ch1.2
- OS Three pieces: ch1
- os_lecture: 20220228第二次课视频 61min

## 预备知识

### CSAPP
考虑到分支预测 流水线 cache_line 等内容在我之前看过的一些书也学过，时间关系这本书我暂时跳过

### RISC-V 版计算机组成原理

为什么不用最常用的 x86 是因为 x86 复杂指令集，ARM/MIPS 虽是精简指令但不开源指令数量非常多

RISC-V 只有 40 多个指令非常适合初学者入门学完之后构建一个操作系统

- 英文书名: computer organization and design RISC-V edition ()
- 中文书名: 计算机组成与设计: 硬件/软件接口

> 另一本经典名著《计算机体系结构量化研究方法》也是同一个出版机构(伯克利分校)出版的

前两章重点看完，后面章节按需看

## textbook
https://pages.cs.wisc.edu/~remzi/OSTEP/

好处一内容面向操作系统的使用者和应用层开发，稍比那些简单

好处二官方有在线阅读的中文版: <https://pages.cs.wisc.edu/~remzi/OSTEP/Chinese/>

### 为什么书名叫 Three Easy Pieces
虚拟化/并发/持久化三个难点三座大山

### 课程实践参考书
- uCore tutorial book
- rCore tutorial book

## 操作系统概述

### 如何定义操作系统
对底层硬件访问进行抽象并虚拟化，控制程序执行过程防止错误(coredump)

### 未来的操作系统?
IOT,分布式操作系统，边缘计算

### 操作系统 bug 非常多
写过操作系统的都知道漏洞非常非常多，多到 bugfix 因此也就有了网络空间安全这样专门找 bug 的专业
