# [sqlx Any 还不成熟](/2023/07/sqlx_any_driver.md)

toB 业务部署上不同的客户会用不同的数据库，如何做到一份代码自动根据数据库协议头去用不同驱动，我看 sqlx::AnyConnection 应该行

The macros generate code that requires a connection of the same kind of database as the DATABASE_URL you compiled with.

There's currently no way to tell the macros to generate code using the Any driver

[Any 不支持宏](https://github.com/launchbadge/sqlx/issues/964)

不光是 query! query_as! 过程宏，连带 sqlx::FromRow 宏的都无法编译

考虑到项目中大量使用 sqlx::FromRow derive 宏导致只能放弃 any 方案
