# 分组

Tags: [数据库](#)

首发于: 18-09-23 最后修改于: 18-09-23

## 聚合(Aggregate)函数

min,max,sum,count,avg,stddev,variance(方差)

若表中无数据则count返回0，而其他统计函数返回NULL

举例-一共有几种职业: SELECT COUNT(DISTINCT job) FROM emp;

## 数据量不一致

所谓聚合, 输入N个记录, 输出却只有一个结果/一行

SELECT sal, AVG(sal) FROM emp;

sal有14行, 而AVG(sal)只有一行, Oracle/MySQL不允许返回的各列记录数不一样

虽然sqlite语法运行, 但会按最少记录数的列为基准截断其它列, 所以不建议这么写

select语句要注意返回的各列长度是否一致

## 分组(GROUP BY)

下面是一个GROUP BY语句示例

```sql
-- 统计各部门人数和平均工资
SELECT e2.deptno, 
       --e2.dname, // select中只能出现分组字段
       Count(e2.sal), 
       Avg(e2.sal) 
FROM   (SELECT e.deptno, 
               d.dname, 
               e.sal 
        FROM   emp e,
               dept d 
        WHERE  e.deptno = d.deptno) e2 -- 子查询内不得有分号 
GROUP  BY e2.deptno;
```

## 多字段分组分组

```sql
-- 各部门的各职业各有几人？
SELECT deptno,
       job,
       count(*)
FROM emp
GROUP BY deptno,
         job
ORDER BY deptno;
```

## HAVING子句

语法/逻辑规定了where语句会在分组前面

如果要对分组后的数据再次进行过滤，则用HAVING子句

业务逻辑：征兵

- 先用WHERE筛选出符合条件的
- GROUPBY为海军、陆军、空军
- 要想选中空军不对，就不能再用where了，where必须在group by前
- HAVING子句过滤出空军(HAVING最大优势可用分组函数)

## HAVING练习1

显示非销售人员职位名称及同职位工资总和(满足大于5000)

```sql
SELECT job, 
       SUM(sal) 
FROM   emp 
WHERE  job != 'SALESMAN' 
GROUP  BY job 
HAVING SUM(sal) > 5000 
ORDER  BY SUM(sal); 
```

## 练习题1

找出工资比SMITH或MARTIN多的员工 的 编号，姓名，工资，领导名，领导工资

```sql
SELECT emp.empno,
       emp.ename,
       emp.sal,
       boss.bossname,
       boss.sal
FROM emp,
  (SELECT empno,
          ename AS bossname,
          sal
   FROM emp) boss
WHERE emp.mgr = boss.empno(+)
  AND emp.sal >
    ( SELECT MIN(sal)
     FROM emp
     WHERE ename IN ('SMITH',
                     'MARTIN') )
ORDER BY emp.empno;

/*
EMPNO ENAME SAL  BOSSNAME SAL
----- ----- ---- -------- ----
 7499 ALLEN 1600 BLAKE    2850
 7521 WARD  1250 BLAKE    2850
 7566 JONES 2975 KING     5000
...
*/
```

## 练习题2

列出各个职位最低工资雇员姓名，工资

```sql
SELECT e.job,
       e.sal,
       e.ename
FROM emp e,

  (SELECT job,
          min(sal) AS MIN
   FROM emp
   GROUP BY job) job
WHERE e.sal = job.min
ORDER BY e.sal;
```