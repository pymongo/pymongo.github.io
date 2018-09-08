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