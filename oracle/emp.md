# emp表练习/LIKE模糊查找

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

## 查询