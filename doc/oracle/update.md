首先复制下emp表，对表的增删改查操作在这个克隆emp表

```sql
-- 该语法是Oracle特有的
CREATE TABLE emp2 AS
SELECT *
FROM emp;
```

## insert into

```sql
INSERT INTO emp2 (empno, ename, job, hiredate)
VALUES(8888,
       'Mike',
       'CLEANER',
       TO_DATE('1970-01-01', 'yyyy-mm-dd'));

-- 插入多行：假设新建了IT部门，需要把IT部门表加到员工表中
INSERT INTO table1 (col1,col2...)
SELECT col1,col2... FROM table2
```

## update and delete

```sql
UPDATE emp2
SET empno=6666,
    hiredate=SYSDATE
WHERE ename = 'Mike';
```

```sql
-- 工资低于水平的雇员全部加薪25%
UPDATE emp2
SET sal = 1.25*sal
WHERE sal <
    (SELECT avg(sal)
     FROM emp2) ;

-- DELETE
DELETE FROM table WHERE xxx;
```

## 事务处理

每个连接到Oracle Server用户的进程

都称为一个Oracle的 **session**

每个session彼此独立不会通信，独享自己的事物控制

A会话中执行的删除操作，在其它会话中看不到此项变更，除非A COMMIT了才会同步数据

事务控制主要用两个命令：COMMIT和ROLLBACK

业务需求：银行A转账B的过程，A转给银行，银行再转给B

中途只要有一步失败(例如银行停电)，就会回滚到初使状态

[事物的特征](https://hit-alibaba.github.io/interview/basic/db/Transaction.html)

脏读(Dirty Read)

当一个事务读取另一个事务尚未提交的修改时，产生脏读。

同一事务内不是脏读。 一个事务开始读取了某行数据，但是另外一个事务已经更新了此数据但没有能够及时提交。这是相当危险的，因为很可能所有的操作都被回滚，也就是说读取出的数据其实是错误的。

事物隔离的实现是通过 锁机制

某个session有未提交的事务，其它session是无法更新的(进入等待状态)

增删改操作都是DML，需要commit

SAVEPOINT语句

<pre>
DML操作1
SAVEPOINT sp1;
DML操作2
SAVEPOINT sp2;
...

ROLLBACK TO sp2
</pre>