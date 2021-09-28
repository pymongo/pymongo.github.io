
调研下 Rust 社区三个 parser generator 库:
1. lalrpop
2. pest
3. nom

## lalrpop

lalrpop 的主要作者是 niko (也是 Rust 语言团队的组长), 用 lalrpop 的知名项目有 RustPython, 而且 lalrpop 的 lr parser 也是用 lalrpop 写出来的(自举)

### context-free grammar LR(1)

从 wikipedia 得知常见的上下文无关文法有: LR(k), LL(K) 等等，pest 库用的 PEG 文法似乎不那么知名


TODO lalrpop 的 LR 括号 1 的括号 1 是什么意思? lyzh 说是 reduce list 的时候一次吃掉一个


[The LALRPOP book](https://lalrpop.github.io/lalrpop)

### TODO ambiguous 逻辑导致编译时死循环

ambiguous 这个词在用 ActiveRecord 这种 ORM 框架生成 SQL 语句时经常遇见

例如 rails/ActiveRecord 中 orders 表通过 user_id 字段 JOIN users 表时会报错 ambiguous

Order.all(:join => :user, :order => :created_at)

因为 ActiveRecord 默认会给所有表都加上 created_at/updated_at 字段，此时 orders 表和 users 表 join 连接到一起后 ActiveRecord 无法得知用哪一个表的 created_at 排序

会产生这样的歧义: 到底用 orders.created_at 还是 users.created_at 进行排序?

解决方法是指定下 created_at 字段是来自哪一个表即可


