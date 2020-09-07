# 数据库笔记

## 复习连接

例如 xxx join on a.id = b.id

本质上都是将两个表通过笛卡尔积合并成一个表后，再根据join on约束条件筛掉一些记录

内连接: a表找不到b.id或b表找不到a.id的记录会被过滤掉

外连接: LEFT/RIGHT/FULL三种，画卡诺图就懂了

相比内连接，左连接保留了b表找不到a.id的记录

## SQL查询优化

### LIMIT 1

确定只查询/更新1条数据，加上LIMIT 1让游标提前停止移动

### 通过EXPLAIN验证查询是否命中缓存

### 像NOW()之类的SQL函数都不会开启查询缓存

例如`WHERE signup_date >= CURDATE()`要改成

`"WHERE signup_date >= ?".bind(chrono::Local::now().date())`

只有当比较符两边的数据是不可变时才能开启查询缓存

### 从 PROCEDURE ANALYSE() 取得建议

`select * from users PROCEDURE ANALYSE()\G`

PROCEDURE ANALYSE() 会让 MySQL 帮你去分析你的字段和其实际的数据，并会给你一些有用的建议

例如 你使用了一个 VARCHAR 字段，因为数据不多，你可能会得到一个让你把它改成 ENUM 的建议

### 使用u32表示IP地址，不要用字符串

因为IPv4地址本身就是32位的

MySQL或C语言的netinet/in.h都有INET_NTOA和INET_ATON实现字符串和u32IP之间互转

INET_ATON('127.0.0.1') = 2130706433
INET_NTOA(2130706433) = '127.0.0.1'

N表示u32整形，A表示字符串格式的IP地址，所以主要看N在那边去记忆转换的方向

### OR会使索引失效应该用UNION

[参考leetcode这道数据库题的题解](https://leetcode-cn.com/problems/big-countries/solution/da-de-guo-jia-by-leetcode/)

使用UNION，如果有一条记录同时满足两种条件，会不会被选择两次呢？

union有distinct默认带功能,union all是不筛选重复,会有两条重复记录

但是由于union去重会消耗性能，所以要根据实际情况去分析，如果or之间重复项不多，就用union，否则用or
