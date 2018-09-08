## 数据库的集合操作

交并补 - UNION、INTERSECT、Except

## 序列-用于AUTO_INCREMENT

```sql
-- 创建一个1,3,5,7循环的序列
CREATE SEQUENCE seq INCREMENT BY 2
START WITH 1 MAXVALUE 10 MINVALUE 1 CYCLE NOCACHE;

-- 自增用法一：
insert into tablename values(seq.nextval,'Mary',15); 

-- 自增用法二：触发器
```

## 视图就是把查询结果打包

建议视图设置为只读 WITH READ ONLY， 不允许修改视图

## 索引

牺牲空间换取查询速度，用于不频繁修改的数据库

例如b树索引，比中间小的放左边，比中间大的放右边

Oracle十几种索引中最简单的就是b树，还有位图、反向、函数索引等等

当表中有主键或UNIQUE约束，索引会被自动创建

## 一些概念

子程序、过程、定义函数、游标、触发器

## SQL优化

- 避免用 *
- UNION、MINUS、INTERSECT、ORDER BY会进行至少两次排序
- DISTINCT至少进行一次排序可用效率更高的DISTINCT代替