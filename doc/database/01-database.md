# 数据库介绍

Tags: [数据库](/)

首发于: 18-09-19 最后修改于: 18-11-19

## 为什么需要数据库

有json字典这样完美的数据结构，也有pickle永久存储数据

我认为依然需要数据库的原因是

编程语言查询query复杂json/List&lt;dict&gt;的效率不行，查询代码冗长可读性差

第二个主要原因是 以文件存储数据 很难实现并发(多人同时访问网页)

## 数据库的分类

除了MongoDB和Redis属于NoSQL(JSON-like), 其它的流行数据库都用SQL语句

Redis是In-memory db, 数据存放在内存, 读写更快

sqlite除了可以把数据存入单个文件, 也可以存在内存中

## 业界用什么数据库

[Database used in most popular websites - Wikipedia](https://en.wikipedia.org/wiki/Programming_languages_used_in_most_popular_websites)

看上去MariaDB,PostgreSQL用得挺多, 不过MySQL的招聘岗位应该是最多的

拉钩网上招任何DBA都是要求会MySQL, Oracle性能虽好但是费用太贵, 免费开源的MySQL最流行

## 数据库学习资源聚合

[在线工具:格式化SQL语句](https://sqlformat.org/)

[数据库英文术语](https://my.oschina.net/seibutu/blog/500298)

[在线sqlite-左边建表右边查询](http://sqlfiddle.com/#!5/d0a2d/6)