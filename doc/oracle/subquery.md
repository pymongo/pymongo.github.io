子查询可以出现在查询语句任意位置，一般用于where和from中

WHERE：子查询一般返回 单行单列(一个值)、多行单列、单行多列

where单行多列比较少用 如 

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

in操作符(注意NULL值问题)

```sql
select * from emp
where sal in (
    select sal from emp where job='MANAGER'
);
```

## ANY和ALL

与每一个内容相匹配，有三种方式

大于/等于或小于ANY

=ANY的功能与IN一样，

>ANY比子查询中最小的还大，>ALL比子查询最大的记录还大

<ANY比最大的还小，<ANY比子查询最小的记录的还小

