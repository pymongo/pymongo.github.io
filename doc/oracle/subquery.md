子查询可以出现在查询语句任意位置，一般用于where和from中

WHERE：子查询一般返回 单行单列(一个值)、多行单列、单行多列、多行多列(用于FROM后)

where 单行(多列) 比较少用 如 

```sql
SELECT * 
FROM   emp 
WHERE ( job, sal ) = (SELECT job, 
                             sal 
                      FROM   emp 
                      WHERE  ename = 'ALLEN'); 
```

## 查询工资高于平均的员工

```sql
SELECT ename, 
       sal 
FROM   emp 
WHERE  sal > (SELECT Avg(sal) 
              FROM   emp); 
```

## 子查询返回单列多行

需要用IN、ANY、ALL指定范围了

IN操作符(注意NULL值问题)

```sql
SELECT *
FROM emp
WHERE sal IN
    ( SELECT sal
     FROM emp
     WHERE job='MANAGER' );
```

与每一个内容相匹配，有三种方式

大于/等于或小于ANY

- =ANY的功能与IN一样，
- &gt;ANY比子查询中最小的还大，>ALL比子查询最大的记录还大

ANY和ALL的作用是为了让单列多行变为一个镇

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