# sqlite

首发于: 18-09-20 最后修改于: 19-01-03

## sqlite的应用领域
- macOS很多自带APP如Notes的数据库就是sqlite
- 嵌入式设备如Android设备
- 浏览器
- [更多应用领域请看维基百科](https://en.wikipedia.org/wiki/SQLite#Notable_users)
- sqlite能快速迭代应用的数据库原型设计或快速验证想法

## sqlite配置

sqlite配置文件: 新建一个`~/.sqliterc` (配置文件很像nano,vim等)

从此进入sqlite shell第一行会提示
`-- Loading resources from C:\Users\w/.sqliterc`

`.headers on` 用于显示字段名

`.mode column` 让输出结果【列左对齐】

## sqlite命令

> 连接sqlite

`sqlite3 [$filename/:memory:]`

!> 若文件不存在, 则会自动创建相应文件, 所以sqlite连接必然成功

如果不指定文件, 会连到内存, 提示
`Connected to a transient in-memory database`

> 【实用】查看当前连接到了哪个文件

`.database[s]`, 如果文件名为空说明连接到内存

`.show`命令可以查看各项配置, 也可查看数据库依附的文件名

!> .databases和.tables命令末尾的s可以省略

退出sqlite除了命令行通用的Ctrl+Z,还有.exit/.quit命令

## in-memory特性与事务

sqlite连接文件, 不会【占用文件】, 多个session连到同一个文件是可以的(并发性), 多个session连接同一个文件时, 某一个session创建表, 其它session也会同步

sql的DDL操作默认都是没开启*事务Transaction*, 所以建表会自动commit, 除非加上BEGIN TRANSACTION;的事务标志, 才可以commit或rollback

但是sqlite连接到内存时, 每个session在内存中的数据都是独立的不会共享的, 并在session结束时清空

## sqlite导入导出命令

> 读写sql脚本

.read $sqlScriptName -- 执行sql脚本

.dump $tableName, dump会将指定表的创建和插入的SQL语句输出

默认下输出到stdout, 随便复制粘贴, 可以通过.output命令修改输出文件

> .sql和.db互相转换

$sqlite3 test.db .dump > test.sql

$sqlite3 test.db < test.sql

> import/export csv

先 .mode csv切换到csv模式

Import csv: .import $csvFilename $tableName

Export csv: .output $csvFilename 然后 select * from $tableName

[写的非常棒的sqlite导入csv教程](http://www.sqlitetutorial.net/sqlite-import-csv/)

## Attach命令:同时连接多个数据库文件

[SQlite附加数据库 - 菜鸟教程](http://www.runoob.com/sqlite/sqlite-attach-database.html)

> sqlite实际上可以在一个shell中操作多个数据库文件

```sql
$ sqlite3 mysql.db
sqlite> attach database 'test.db' as 'test';
sqlite> .databases
main: C:\Users\w\temp\mysql.db
test: C:\Users\w\temp\test.db
```
