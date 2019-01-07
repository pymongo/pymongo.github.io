# sql基础知识

首发于: 18-09-21 最后修改于: 10-01-07

## 字符串与别名

> select from 虚拟表

如果仅仅是为了验证一个表达式的结果, 可以不需要from子句

MySQL和sqlite可以直接`select 1+1;`而Oracle需要`select 表达式 from dual`

> 字符串的表示

sqlite/MySQL单双引号都可以表示字符串, Oracle单引号才是普通字符串, Oracle的双引号一般用于*别名*/用户名/表名/字段名, SQL语句执行前都会转为大写, 用引号括住的部分【会区分大小写】

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
LIMIT 3 OFFSET 5; -- LIMIT不能结合BETWEEN AND关键字
/*
ename: sal
-----------
BLAKE: 2850
CLARK: 2450
SCOTT: 3000
*/
-- Oracle的BETWEEN可用于datatime
```

## NULL

- 表达式中有NULL则结果为NULL
- 除了加减乘除，IN操作符碰上NULL返回也是NULL
- 用nvl函数使得操作数有NULL但结果会输出0而不是无意义的NULL


## 工资降序排列，若相同则按工龄

```sql
SELECT *
FROM emp
ORDER BY sal DESC, hiredate;
```

## 模糊查找like的匹配字符

- _ 匹配单个字符
- % 匹配0个或1个或多个字符
- $ 用来转义_和%

> 模糊查询示例:

```sql
-- 查询以A开头的员工姓名
SELECT * 
FROM emp
WHERE ename LIKE 'A%';
-- 含A写法: LIKE '%A%';
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

!> 这也是网页分页查询的sql语句实现

## 子查询简介

子查询一般用于where和from中, 与分组/聚合函数一样需要注意数据长度对齐

```sql
-- 子查询返回多行多列, 如何保证数据长度一致
SELECT * 
FROM   emp 
WHERE ( job, sal ) =
  ( SELECT job, sal 
    FROM   emp 
    WHERE  ename = 'ALLEN' ); 
```

> 子查询返回多行单列

需要用IN、ANY、ALL指定范围了

```sql
SELECT *
FROM emp
WHERE sal IN
  ( SELECT sal
    FROM emp
    WHERE job='MANAGER' );
```

> ANY和ALL

```sql
WHERE column_name operator ANY
(SELECT column_name FROM table_name WHERE condition);
```

= ANY的功能与IN一样, &gt;ANY比子查询中最小的还大，>ALL比子查询最大的记录还大

ANY和ALL的作用是为了让单列多行的数据聚合为一个值

## 【重要】查询每个部门名字、地点、人数、平均工资

```sql
-- 1、获取部门表的部门名、部门编号、部门地点
SELECT d.dname,
       d.deptno,
       d.loc
FROM dept d;

-- 2、雇员表中按部门分组，各部门的人数和平均工资
SELECT e.deptno, COUNT(e.empno) AS "empNum",
       AVG(e.sal)
FROM emp e
GROUP BY e.deptno;

SELECT d.dname,
       d.deptno,
       d.loc,
       temp.empnum,
       temp.empsal
FROM dept d,
  (SELECT e.deptno,
          COUNT(e.empno) AS empnum,
          AVG(e.sal) AS empsal
   FROM emp e
   GROUP BY e.deptno) TEMP
WHERE d.deptno = temp.deptno(+);

/*
DNAME              DEPTNO LOC               EMPNUM     EMPSAL
-------------- ---------- ------------- ---------- ----------
ACCOUNTING             10 NEW YORK               3 2916.66667
RESEARCH               20 DALLAS                 5       2175
SALES                  30 CHICAGO                6 1566.66667
OPERATIONS             40 BOSTON
*/
```

## 字符串处理常用函数

UPPER, INITCAP(首字母大写), LENGTH, REPLACE, SUBSTR, CONCAT

LPAD('123',5,'000') = 00123 -- 这个有点像python的zfill

Oracle中 substr等函数索引 从0或1开始结果都是一样的

## ROUND函数和TRUNC函数

用于浮点数数/日期 的 **四舍五入**, 第二个参数为负数时, -1表示小数点左边一位, 如ROUND(5,-1)=10, ROUND(45,-2)=0(以十位的4为标准四舍五入), 第二个参数为正数时表示包留X位小数

**TRUNC函数的语法和ROUND一模一样**

TRUNC(45,-1)表示只要从个位往左的数据, TRUNC的功能像截取数字，TRUNC(12.34, 1)=12.3, floor(n):返回小于等于n的最大整数； ceil(n)：返回大于等于n的最小整数

## 示例:计算员工工龄(年数)

```sql
SELECT ename,
       TRUNC(MONTHS_BETWEEN(SYSDATE,hiredate)/12) AS "seniority",
       sal AS "Salary"
FROM emp
ORDER BY "seniority" DESC;
```

## 格式化datetime字符串

TO_CHAR(operand, '格式化字符串')

Oracle中的日期类型实际存储的是时间戳

```sql
SELECT TO_CHAR(SYSDATE,'yyyy-mm-dd hh24:mi:ss')
FROM dual;
-- 2018-08-21 19:08:28
```

TO_DATE函数将一个字符串按照格式化字符串变为日期

```sql
SELECT TO_DATE('2019-9-1','yyyy-mm-dd')
FROM dual;
-- 01-SEP-19
```

```sql
SELECT TO_CHAR(12345678,'L99,999,999') -- 9表示一位数字
FROM dual;
-- L表示系统语言所在国家货币符号
-- $12,345,678
```

## 综合应用:计算工作了几年几月几日

我花了大量时间依然没解决 天数 转 日期

因为天数是无法转换为20XX年的

先求年份，再求月份，最后求时第几天

月份 = months % 12

!> 求天数，最准确是不超过30天的范围内求(不然容易闰年等)

```sql
SELECT ename, 
       hiredate, 
       Trunc(Months_between(SYSDATE, hiredate) / 12) Years, 
       MOD(Trunc(Months_between(SYSDATE, hiredate)), 12) Months, 
       Trunc(SYSDATE - Add_months(hiredate, Months_between(SYSDATE, hiredate)))Days 
FROM   emp 
ORDER  BY years DESC, 
          months DESC, 
          days DESC; 
/*
ENAME      HIREDATE       YEARS     MONTHS       DAYS
---------- --------- ---------- ---------- ----------
SMITH      17-DEC-80         37          8          4
ALLEN      20-FEB-81         37          6          1
*/
```

## 数据库的集合操作

交并补 - UNION、INTERSECT、Except
