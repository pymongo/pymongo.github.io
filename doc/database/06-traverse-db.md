# 数据库的组成



首发于: 18-11-19 最后修改于: 18-11-19

## 数据库的组成

数据库由多个~~用户~~(schema), schema一般和用户名相同

每个~~用户~~(schema)有多个*表(table)*

每个表有多个*字段/列(field)*

表中的一行称为一个*记录(record)*

## schema

schema是数据库对象的集合, 如:表、视图、存储过程、索引等

user own it's schema, 创建用户的时候自动会创建用户同名的schema

用户是用来连接数据库的, 数据是在schema中, 完整的表名应该是 schema.table

## list schemas/tables/fields

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
-- sqlplus scott/scott
-- 如果scott想用hr的emp表, 只能通过表的完整名hr.emp引用
SHOW user; -- get using schema name
SELECT * FROM tab; -- list the tables
DESC $tableName; -- 列出字段名与【MySQL完全一样】
```

> sqlite

```sql
.databases/.show -- 列出连到的是哪个文件
.tables -- 列出当前文件的所有表名
.schema $tableName -- 查询$tableName表的字段
```
