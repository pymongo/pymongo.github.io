## 查询工资在2k-2.5k之间的经理

```sql
SELECT *
FROM emp
WHERE job='MANAGER'
      AND sal BETWEEN 2000 AND 2500;
```

## 查询1987年入职的员工

!> BETWEEN AND除了可读性更强，还能选中「日期」范围

```sql
SELECT *
FROM emp
WHERE hiredate BETWEEN '01-JAN-87' AND '31-DEC-87';
```

## NULL

- 表达式中有NULL结果为NULL
- 除了加减乘除，IN操作符碰上NULL返回也是NULL
- 关于null的处理有nvl函数

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