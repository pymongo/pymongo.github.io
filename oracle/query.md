# 查询/别名/字符串

## 获取当前用户名

`SHOW user`

想要访问其它用户的表，必须用表的完整名——用户名.表名 或 模式名.表名

## 列出当前用户下所有表

`SELECT * FROM tab;`

## 查看某个表的所有字段/fields

`DESC hr.departments`

---

## 别名

查询的模板(举个例子)

> DISTINCT关键字用于去重

`SELECT [DISTINCT] *|field1[alias][,field2[alias]] FROM table1[alias] WHERE xxx`

获取emp员工表的 年薪

!> 别名中有空格要用双引号括起来

```sql
SELECT ename,
       sal*12 AS "Annual Salary"
FROM emp;

ENAME      Annual Salary
---------- -------------
SMITH               9600
...
```

## 单引号表示字符串

!> ||表示字符串拼接(concatenation)

```sql
SQL> SELECT ename || ': ' || sal FROM emp;

ENAME||':'||SAL
------------------
SMITH: 800
...
```

## 像json一样打印员工信息

```sql
SELECT ' Job number:'||empno
     ||' Name:'||ename
     ||' Salary:'||sal
     AS "employees' infomation"
FROM emp;

employees' infomation
---------------------------------------
 Job number:7369 Name:SMITH Salary:800
...
```

---

## dual虚拟表

如果仅仅是想print一下Oracle的表达式

但Oracleselect语句必须有from，所以可以用

SELECT 'Mike''s apple' FROM dual;

## 注意where中字符串要大写

...WHERE job = 'manager'; -- no rows selected

...where job = 'MANAGER'; -- ok

## 总结下别名/引号

别名：

- 别名的作用是「多表查询」时区分哪个字段时哪个表的(避免重名)
- Oracle中表别名没有AS关键字

字符串：

- Oracle在解释sql语句时会全部转换为大写再进行操作
- 如创建表的时候表名用双引号，则表名区分大小写
- 用户名/表名/字段名/别名可用双引号，见<a href="/img/oracle/oem-departments-data.png">OEM一文打印部门表的图</a>
- 单引号可以转义(escape)单引号 例如 'I''am' -> I'am