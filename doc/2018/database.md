# 数据库介绍

## 为什么需要数据库

1. 编程语言query(查询)json的效率不行，查询代码冗长可读性差

2. 数据库可以高并发地读取数据(多人同时访问网页)

3. 相比直接用文本形式或序列化形式(如pickle), 数据库存储数据的效率更高

## 数据库的分类

除了MongoDB和Redis属于NoSQL(JSON-like), 其它的流行数据库都用SQL语句

Redis是In-memory db, 数据存放在内存, 读写更快

sqlite除了可以把数据存入单个文件, 也可以存在内存中

## 业界用什么数据库

[Database used in most popular websites - Wikipedia](https://en.wikipedia.org/wiki/Programming_languages_used_in_most_popular_websites)

哪种数据库有市场(岗位多)? => MySQL

## 数据库学习资源聚合

- [在线工具:格式化SQL语句](https://sqlformat.org/)

- [数据库英文术语](https://my.oschina.net/seibutu/blog/500298)

- [在线sqlite-左边建表右边查询](http://sqlfiddle.com/#!5/d0a2d/6)

## 数据库的组成

数据库由多个~~用户~~(schema), schema一般和用户名相同

每个~~用户~~(schema)有多个*表(table)*

每个表有多个*字段/列(field)*

表中的一行称为一个*记录(record)*

## schema

schema是数据库对象的集合, 如:表、视图、存储过程、索引等

user own it's schema, 创建用户的时候自动会创建用户同名的schema, 用户是用来连接数据库的, 数据是在schema中, 完整的表名应该是 schema.table

## 「遍历数据库」list schemas/tables/fields

> SQLite

```sql
.databases/.show -- 列出连到的是哪个文件
.tables -- 列出当前文件的所有表名
.schema $tableName -- 查询$tableName表的字段
```

> MySQL

```sql
SHOW DATABASES; -- list the schemas
USE test;
SELECT DATABASE(); -- get using schema name
SHOW TABLES; -- list the tables
DESC $tableName; -- list all fields of $tableName
```

> Oracle

```sql
-- sqlplus scott/scott (用户名/密码)
SHOW user; -- get using schema name
SELECT * FROM tab; -- list the tables
DESC $tableName; -- 列出字段名与【MySQL完全一样】
```
