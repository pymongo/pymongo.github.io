# 增删改,约束与事务处理

首发于: 18-09-23 后修改于: 19-01-04

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

## 表操作

复制表结构(写个不满足的条件即可)

```sql
CREATE TABLE empnull AS
SELECT *
FROM emp
WHERE 1=0;
```

删除表/字段用drop，注意Oracle有回收站机制

```sql
ALTER TABLE %tablename
    ADD/MODIFY (
        字段1 1的类型 [可选项],
        字段2 2的类型 [可选项]
    );
```

创建数据库的流程：
删除同名表->创建表->插入测试数据->事物提交

## 约束

```sql
-- 五种约束
NOT NULL -- NK
UNIQUE -- UK
PRIMARY KEY -- PK 非空+唯一
FOREIGN KEY
CHECK -- PK 增加过滤条件
```

```sql
-- 例子
CREATE TABLE member (
    id int,
    email VARCHAR(20),
    sex VARCHAR(8) NOT NULL,
    -- 定义约束名，使错误信息可读性更强
    CONSTRAINT uk_email UNIQUE(email),
    -- 复合主键，两个字段都一样才算重复，基本不用
    CONSTRAINT pk_id PRIMARY kEY(id,email)
    CONSTRAINT ck_sex CHECK(sex in ('male','female'))
)
```

## 主外键约束(重要)

一对一、一对多、多对多(多个同学选了不同的课)，一般是

让学生选课名称的取值范围由另一个表绝对，这就是外键约束

```sql
create table lession(
    lid int,
    name VARCHAR(20) NOT NULL,
    CONSTRAINT pk_lid PRIMARY KEY(lid)
);
create table student(
    sid int,
    name VARCHAR(20) NOT NULL,
    CONSTRAINT pk_sid PRIMARY KEY(sid)
);
insert into lession values(1,'math');
insert into lession values(2,'english');
insert into lession values(1,'aa');
insert into lession values(2,'bb');
```

外键约束的类型有三种：

on no action：默认 A部门有人不能直接删掉A部门字段

ON DELETE set null：删掉A部门后，原A部门雇员的部门编号设为NULL

ON DELETE cascade级联 删掉A部门后同时删掉A部门所有雇员的记录

## 修改约束

```sql
-- 如果表中存在违反年龄条件的数据
-- 则会报错，必须先处理掉非法数据
ALTER TABLE student 
ADD CONSTRAINT ck_age
CHECK (age BETWEEN 16 AND 25);

ALTER TABLE student
DROP CONSTRAINT pk_mid;
```

如果不知道约束名，可以去查询

!> 非空约束无法增删改

## AUTO_INCREMENT

Oracle没有mysql/sqlite的 AUTO_INCREMENT 关键字

Oracle通过序列或触发器实现自动自增
