# [测量数据库查询时间](2019/11_1/measure-qurey-time)

优化数据库查询之前，首先需要有一个工具能测量查询时间。

## 为什么不通过ruby测时间

ruby不是一个专业的SQL语句执行时间的工具。

## PROFILES

syntax:

```sql
SET profiling = 1;

SELECT COUNT(*) FROM orders;

SHOW profiles;
```

example:

```sql
mysql> select count(*) from orders;
+----------+
| count(*) |
+----------+
|  8031334 |
+----------+
1 row in set (0.76 sec)

mysql> show profiles;
+----------+------------+-----------------------------+
| Query_ID | Duration   | Query                       |
+----------+------------+-----------------------------+
|        1 | 0.75605400 | select count(*) from orders |
+----------+------------+-----------------------------+
1 row in set, 1 warning (0.00 sec)
```

### profile和profiles

> show profile -- 显示上次查询过程中每个步骤的耗时

> show profiles -- 显示查询历史中每条记录的查询耗时

### sql_no_cache

在select语句后一个单词加上sql_no_cache的选项

可以反映出没有缓存下更为真实的查询速度

!> Warning: SQL_NO_CACHE' is deprecated and will be removed in a future release

## mysql slow

据说超过20秒的查询会被记入mysql slow日志

## timeit? benchmark?

有没有类似python的timeit那样 查询100次取查询时间的平均值

或者像apache benchmark

