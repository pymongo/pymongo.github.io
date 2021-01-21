# [PR: sqlx sqlite编译时死循环](/2021/01/sqlx_sqlite_group_by_infinite_loop.md)

最近sqlx的issue[#981](https://github.com/launchbadge/sqlx/issues/981)
吸引了我，如果sqlite的SQL语句出现GROUP BY那么会在编译时SQL检查时陷入死循环

sqlx编译时SQL语句检查主要是通过explain来实现，我的理解是如果prepare statement有参数绑定，那么就替换成默认值

分析数据库explain SQL语句的返回值来判断SQL语句有没有写错之类的

sqlite的explain返回的是一个opcode-operands的数组，opcode会有类似Goto这样的命令在数组中跳转

有人用python写了个opcode-operands数组的[解析器](https://github.com/asutherland/grok-sqlite-explain)
，能将opcode-operands数组转为graphviz图片

我捣鼓了一会没搞懂它这工具怎么用，而且还需要debug开启下编译生成的sqlite可执行文件

我粗略的看了下sqlite bytecode engine的文档和vdbe.c源文件，对比了下`sqlx-core/src/sqlite/connection/explain.rs`中对opcode的解析

sqlx并没有对所有opcode进行解析，而且仅explain语句的返回值要解析opcode，其它正常的查询都不用，可能sqlx的作者仅解析explain中有必要的opcode吧

由于我自身对数据库方面的领域知识不足，sqlite bytecode的文档看得很费劲，编译时死循环的原因两个Goto的opcode互跳，

于是我用一个比较dirty way的解决办法: 像leetcode BFS题解决图中有环死循环那样，加一个visited布尔值数据就能保证每个opcode仅执行一次

更理想的解决方案是enhance sqlite explain的处理代码，可惜我能力有限没能实现
