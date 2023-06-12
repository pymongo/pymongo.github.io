# [sqlx schema bug](/2023/06/sqlx_sqlite_schema_bug.md)

在 sqlx 社区看到一个有趣且含金量很高的 issue [sqlite bug](https://github.com/launchbadge/sqlx/issues/2517)

汇报者来自国内 rustcc 社区的 see web 框架的作者，很可能作者最近在整合 sqlx 进 web 框架遇到的 sqlx

sqlx 又是业界 Rust 后端业务几乎必备的模块，只要有状态的业务就会有数据库，Rust 操作数据库几乎必用 sqlx

看到有人踩坑还是很有必要记录下

## 复现步骤

sqlite alter 某张表后再 select 这张表，alter 后第一次 select 会用旧的 schema 第二次则用新的 schema

## 捣鼓原因

我一开始我在错误的设想是不是修改表结构事务没有 commit

结果加上 begin/commit 也一样，gpt 也说 sqlite 的 alter 语句自动会加上事务，会 block 住后续的查询

于是我想能不能在每次查询前列出下表结构

sqlite 没有 show create table, 但有以下几种方式 describe table
- .schema table_name
- PRAGMA table_info(table_name)
- SELECT * from pragma_table_info('user');

接下来我猜测是不是连接池中有连接读到未提交的事务，但是 sqlite 是单连接，sqlx 文档也说 sqlx-sqlite 的读写是 Serial 的

既然每次表结构变动 schema_version 都会加一，果然用 PRAGMA schema_version 去查 alter 之后每次查询的 schema_version 都是一样的，都是 alter 之前的版本号 +1

> gpt: Periodically or when the WAL file exceeds a certain size, SQLite3 will merge the changes from the WAL file into the main database file on disk. This process is called a checkpoint

sqlite WAL 进行持久化(checkpoint)过程或者修改表结构的时候都会拿写锁，会 block 所有读写操作，所以原因只可能是 sqlx 自身 bug

## sqlx-sqlite 执行流程

在源码中搜索 Command::Execute 的生产者和消费者，消费者就是 SqliteConnection 的 worker 线程(只有一个) 就能梳理出 sqlx 查询流程

1. conn.statements.get 获取查询缓存
2. self.statement.prepare_next 没缓存的话就通过 FFI 接口 prepare 获取下 `select *` 返回哪些字段
3. 执行查询
4. 如果使用了缓存，就清空缓存

alter table 之后查询该表，sqlx 就会 134, 234 这样的步骤交替出现

## bug 影响

query_as 反序列成结构体的话，如果先前进行了 alter table 操作，会字段名对不上导致查询报错

规避方法就是，要进行 sqlite alter 操作就 new 一个连接单独操作再析构，不要污染主要的连接
