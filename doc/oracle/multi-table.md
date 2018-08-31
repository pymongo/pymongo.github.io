## 不想要的笛卡尔积

多表查询时，字段名前加上表名能加快数据库访问

```sql
SELECT emp.ename, 
       emp.deptno, 
       dept.dname, 
       dept.loc 
FROM   emp, 
       dept; 
```

emp表有14个记录，dept表有4个记录

查询结果是14*4个记录

## 【重点】多表查询性能差

```sql
SELECT emp.ename, 
       emp.deptno, 
       dept.dname, 
       dept.loc 
FROM   emp, 
       dept
WHERE  emp.deptno = dept.deptno;
```

此时只在【显示上】消除了笛卡尔积，

因为数据库的操作机制属于逐行进行数据的判断

如果数据量很大，等值查询性能很差

!> 可用子查询实现多表查询

## 自然连接(不指定字段)

```sql
SELECT e.ename, 
       -- d.deptno, 不能select两个表相同字段
       d.dname, 
       d.loc 
FROM   emp e
NATURAL JOIN dept d;
```

## JOIN USING

使用USING子句明确指定连接字段

```sql
SELECT e.ename,
       d.dname, 
       d.loc 
FROM   emp e
JOIN   dept d
USING  (deptno);
```

## JOIN ON

```sql
SELECT e.ename,
       d.dname, 
       d.loc 
FROM   emp e
JOIN   dept d
ON  (e.deptno = d.deptno);
-- ON更灵活些，两个表的字段名可以不同
```

## 查看工资等级

```sql
SELECT e.ename, 
       e.sal, 
       s.grade 
FROM   emp e, 
       salgrade s 
WHERE  e.sal BETWEEN s.losal AND s.hisal; 

/*
ENAME             SAL      GRADE
---------- ---------- ----------
SMITH             800          1

原理：比如SMITH的工资时800，去s表查询时，
只有grade1这行满足between...and条件
*/
```

## 自关联(自己连接自己)

查询每个雇员的领导名字

每个员工的MGR字段(领导)也是个员工ID

```sql
SELECT e.empno, 
       e.ename, 
       boss.ename 
FROM   emp e, 
       emp boss 
WHERE  e.mgr = boss.empno; 
```

然而发现结果少了一列，因为主席/总裁上面没有领导

这时就需要左/右连接来解决这个问题

## 【重要】左右连接

左右指的是查询判断条件的参考方向

(+)放在等号左边就是左连接

```sql
SELECT * 
FROM   emp e, 
       dept d 
WHERE  e.deptno = d.deptno; 
```

明明dept表中有40部门，输出结果中却没有

原因是就没有员工在40部门，如果非要显示40部门，就用左/右连接

```sql
SELECT * 
FROM   emp e, 
       dept d 
WHERE  e.deptno(+) = d.deptno;
-- 此时多了一个记录，该记录除了deptno为40其余为NULL
```

!> 不用刻意区分是左是右，如果有些想要的数据没出来，就更改参考方向

```sql
-- 查询每个员工的领导名
SELECT e.empno, 
       e.ename, 
       boss.ename 
FROM   emp e, 
       emp boss 
WHERE  e.mgr = boss.empno(+); 
```

这个(+)号是Oracle特有的

## 总结

<img src="/img/oracle/join.png">