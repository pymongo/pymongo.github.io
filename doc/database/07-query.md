# 字符串与模糊查询



首发于: 18-09-21 最后修改于: 18-11-18

## 字符串与别名

> select from 虚拟表

如果仅仅是为了验证一个表达式的结果, 可以不需要from子句

MySQL和sqlite可以直接`select 1+1;`而Oracle需要`select 表达式 from dual`

> 字符串的表示

sqlite/MySQL单双引号都可以表示字符串, Oracle单引号才是普通字符串

Oracle的双引号一般用于*别名*/用户名/表名/字段名

> Q:为什么要引号/【如何区分大小写】

A: SQL语句执行前都会转为大写, 用引号括住的部分【会区分大小写】

> 字符串拼接

Oracle/sqlite 用||拼接字符串, MySQL用CONCAT函数

> 别名

- 别名的作用是「多表查询」时区分哪个字段时哪个表的(避免重名)
- 别名还可以增加输出结果的可读性
- Oracle中表别名前不能加AS关键字

```sql
-- 查询/别名示例
SELECT
    ename||': '||sal AS 'ename: sal'
FROM
    emp
LIMIT 3 OFFSET 5;
-- LIMIT不能结合BETWEEN AND关键字
/*
ename: sal
-----------
BLAKE: 2850
CLARK: 2450
SCOTT: 3000
*/
```

Oracle的BETWEEN可用于日期时间

87年入职: WHERE hiredate BETWEEN '01-JAN-87' AND '31-DEC-87';

## NULL

- 表达式中有NULL则结果为NULL
- 除了加减乘除，IN操作符碰上NULL返回也是NULL
- 用nvl函数使得操作数有NULL但结果会输出0而不是无意义的NULL

## 模糊查找like

先认识几个 LIKE的匹配字符

- _ 匹配单个字符
- % 匹配0/1/多个字符
- $ 用来转义_和%

## 查询以A开头的员工姓名

```sql
SELECT * 
FROM emp
WHERE ename LIKE 'A%';
```

## 含A和不含A的员工姓名

写出含A即可，不含A加个NOT够了

```sql
SELECT *
FROM emp
WHERE ename LIKE '%A%';
```

LIKE子句不仅可以用于字符串，而且可用于任意数据类型

## 工资降序排列，若相同则按工龄(入职时间)

```sql
SELECT *
FROM emp
ORDER BY sal DESC, hiredate;
```

## limit/rownum(伪列)

> 需求：只看结果的前十行

```sql
-- MySQL/SQLite
SELECT column_name(s)
FROM table_name
WHERE condition
LIMIT number;
```

```sql
-- Oracle
SELECT column_name(s)
FROM table_name
WHERE ROWNUM <= number;
```