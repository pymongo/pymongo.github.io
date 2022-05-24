# [看函数调用链路/树](/2022/05/vscode_show_call_hierarchy.md)

侵入式的函数 call graph 追踪有 kcachegrind, uftrace

而 vscode ra 基于静态分析的函数调用树查询就很有用了，帮助新人理解项目代码从 main 函数怎样一步步调用到当前函数

就像看 gdb 的 backtrace 一样可以一帧帧逐帧解析代码运行过程

TODO Intellij Idea 的类似功能在哪看

![](/2022/05/vscode_show_call_hierarchy.png)
