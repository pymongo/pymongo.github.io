# 数据库介绍

Tags: [数据库](/)

首发于: 18-09-19 最后修改于: 18-09-20

## 数据库的分类

除了MongoDB和Redis属于NoSQL(JSON-like), 其它的流行数据库都用SQL语句

Redis是In-memory db, 数据存放在内存, 读写更快

sqlite除了可以把数据存入单个文件, 也可以存在内存中

## 业界用什么数据库

[Database used in most popular websites - Wikipedia](https://en.wikipedia.org/wiki/Programming_languages_used_in_most_popular_websites)

看上去MariaDB,PostgreSQL用得挺多, 不过MySQL的招聘岗位应该是最多的

拉钩网上招任何DBA都是要求会MySQL, Oracle性能虽好但是费用太贵, 免费开源的MySQL最流行

## 数据库的组成

数据库由多个~~用户~~(schema), schema一般和用户名相同

每个~~用户~~(schema)有多个*表(table)*

每个表有多个*字段/列(field)*

表中的一行称为一个*记录(record)*

## schema

schema是数据库对象的集合, 如:表、视图、存储过程、索引等

user own it's schema, 创建用户的时候自动会创建用户同名的schema

用户是用来连接数据库的, 数据是在schema中, 完整的表名应该是 schema.table


## 数据库学习资源聚合

[在线工具:格式化SQL语句](https://sqlformat.org/)

[数据库英文术语](https://my.oschina.net/seibutu/blog/500298)

[在线sqlite-左边建表右边查询](http://sqlfiddle.com/#!5/d0a2d/6)