## 字符串相关的常用函数

输入参数：字符串 或 字段field

UPPER, LOWER, INITCAP(首字母大写), LENGTH

REPLACE(ename, 'S', '*'), SUBSTR, CONCAT

字符串查找INSTR(input, char, [, start][, n])

n表示返回第n次找到的索引

LPAD,RPAD(input,n,char)从左边或右边用char填充至总长度为n

LPAD('123',5,'000') = 00123

LPAD('123',2,'000') = 12

## 用户输入(类似python的input)

```sql
SELECT *
FROM emp
WHERE ename = UPPER('&str');

/*
Enter value for str: smith
old   3: WHERE ename = UPPER('&str')
new   3: WHERE ename = UPPER('smith')

EMPNO ENAME ...   
----- -----
7369  SMITH ...     
*/
```

## SUBSTR函数

回顾些英文术语lisp expression, operand

用法一： SUBSTR(operand, start) 从strat位置开始一直到结束

用法二： SUBSTR(operand, start, end)

start/end索引可以用负数

!> Oracle中 substr 0到3 和 1到3 结果是一样的

SELECT SUBSTR(ename, 0, 3) FROM emp;

SELECT SUBSTR(ename, 1, 3) FROM emp; // same

## ROUND函数和TRUNC函数

**四舍五入** ，语法 ROUND(operand, [arg])

第二个参数为负数时，-1表示小数点左边一位

如ROUND(5,-1)=10, ROUND(45,-2)=0(以十位的4为标准四舍五入)

第二个参数为正数时表示包留X位小数

**TRUNC函数的语法和ROUND一模一样**

TRUNC(45,-1)表示只要个位往左的

TRUNC的功能像截取数字，TRUNC(12.34, 1)=12.3

floor(n):返回小于等于n的最大整数； ceil(n)：返回大于等于n的最小整数

~~ROUND和TRUNC函数也能对日期类型进行处理(一般不用)~~

## 日期

获取当前日期 `SELECT SYSDATE FROM dual;`

!> 日期类型可以 **加减** 数字

## 计算员工工龄

```sql
SELECT ename,
       SYSDATE-hiredate AS "seniority",
       sal AS "Salary"
FROM emp
ORDER BY "seniority" DESC;
```

显示的是天数，而且还是小数，我们希望看到的工龄时年数

```sql
SELECT ename,
       TRUNC(MONTHS_BETWEEN(SYSDATE,hiredate)/12) AS "seniority",
       sal AS "Salary"
FROM emp
ORDER BY "seniority" DESC;
```

## 日期函数

LAST_DAY(date) 求出所给日期的本月最后一天

NEXT_DAY(date, weekday) 所给日期的下一个weekday(星期几)

ADD_MONTHS(date, int), MONTHS_BETWEEN(date1,date2)

## 格式化日期时间字符串

TO_CHAR(operand, '格式化字符串')

Oracle中的日期类型实际存储的是时间戳

```sql
SELECT TO_CHAR(SYSDATE,'yyyy-mm-dd hh24:mi:ss')
FROM dual;
-- 2018-08-21 19:08:28
```

如果不希望8月前面补0，可在格式化字符串加上fm前缀

```sql
SELECT TO_CHAR(SYSDATE,'fmyyyy-mm-dd hh24:mi:ss')
FROM dual;
-- 2018-8-21 19:8:32
```

TO_DATE函数将一个字符串按照格式化字符串变为日期

一般再更新数据库时使用较多

```sql
SELECT TO_DATE('2019-9-1','yyyy-mm-dd')
FROM dual;
-- 01-SEP-19
```

## TO_CHAR让数字输出更好看

```sql
SELECT TO_CHAR(12345678,'L99,999,999') -- 9表示一位数字
FROM dual;
-- L表示系统语言所在国家货币符号
-- $12,345,678
```

## NVL函数

NVL和DECODE，这两个函数算Oracle的特色

假如年薪的计算公式时：(月薪+奖金)*12

但是有的雇员奖金为NULL，而我们知道表达式遇上NULL结果也为NULL

所以这时候就需要NVL函数了 (sal+NVL(comm,0))*12

NVL2函数(字段|表达式, value1 if NOT NULL, else:value2)

COALESCE ( expression, expression [ , ...] ) 

返回列表中的第一个非空表达式。

## DECODE函数

相似的语句 **[CASE语句](http://exceptioneye.iteye.com/blog/1197329)**

语法 DECODE(数值|字段，判断值1，显示值1[，判断值2，显示值2])

```sql
SELECT ename,
       job,
       DECODE(job, 'CLERK', 'girl',
                   'MANAGER', 'boy')
FROM emp;
/*
ENAME      JOB       DECO
---------- --------- ----
SMITH      CLERK     girl
ALLEN      SALESMAN
WARD       SALESMAN
JONES      MANAGER   boy
*/
```

decode怎么感觉很像replace，

decode把一个字段中的内容进行判断，

如满足相应条件则完全替换为相应结果，

如用replace函数，则不能把多个replace结果显示到同一列中

## 计算工龄2-格式化显示

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
       Trunc(SYSDATE - Add_months(hiredate, Months_between(SYSDATE, hiredate))) Days 
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
