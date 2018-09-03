Oracle没有MySQL的 LIMIT 关键字，类似的功能是ROWNUM

```sql
-- 行号演示/有点像Excel
SELECT rownum,ename FROM emp;
-- 查询前五条记录
WHERE rownum <= 5;
```

## 查询6-10条记录

按照正常的思维肯定是用BETWEEN AND

但是rownum是伪列，不能用于BETWEEN

方法一：应该先查询前10条，再查询后5条(子查询实现)

```sql
-- 方法二
SELECT *
FROM
  ( SELECT rownum AS r,
           ename
   FROM emp)
WHERE r BETWEEN 6 AND 10;

-- 方法三【Oracle12以上】
SELECT empno, sal
FROM   emp
ORDER BY sal
OFFSET 4 ROWS FETCH NEXT 4 ROWS ONLY;
```

应用：分页查询记录(如浏览第二页的帖子)

## ROWID - 记录地址

ROWID是记录存储地址

```sql
SQL> select rownum,rowid,ename from emp;

ROWNUM ROWID              ENAME
------ ------------------ ----------
     1 AAAR3sAAEAAAACXAAA SMITH
     2 AAAR3sAAEAAAACXAAB ALLEN
     3 AAAR3sAAEAAAACXAAC WARD
```

rowid AAAR3s AAE AAAACX AAA 的组成

- 数据对象号：AAAR3s  
- 相对文件号：AAE
- 数据块号：AAAACX
- 数据行号：AAA(越早的数据rowid越小)

ROWID的作用——删除表中重复记录

## 一道ROWID的面试题

```sql
-- 有人对部门表进行不慎操作后
INSERT INTO dept VALUES(11,'ACCOUNTING','NEW YORK');
INSERT INTO dept VALUES(17,'ACCOUNTING','NEW YORK');
INSERT INTO dept VALUES(13,'ACCOUNTING','NEW YORK');
INSERT INTO dept VALUES(36,'SALES','CHICAGO');
COMMIT;
-- 部门表变为
DEPTNO DNAME          LOC
------ -------------- -------------
    11 ACCOUNTING     NEW YORK
    17 ACCOUNTING     NEW YORK
    13 ACCOUNTING     NEW YORK
    36 SALES          CHICAGO
    10 ACCOUNTING     NEW YORK
    20 RESEARCH       DALLAS
    30 SALES          CHICAGO
    40 OPERATIONS     BOSTON

-- 如何以最早的数据为基础去掉重复的行
-- 这个SQL语句是可行的，不过由于主外键约束被禁止
FROM dept
WHERE ROWID NOT IN
    (SELECT MIN(ROWID)
     FROM dept
     GROUP BY dname,
              loc);
```

delete from dept
where deptno in (11,17,13,36);