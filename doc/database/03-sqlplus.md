# sqlplus

Tags: [数据库](#)

首发于: 18-09-20 最后修改于: 18-09-20

## 连接/切换用户

> 连接用户

`sqlplus scott/scott` 或 `sqlplus / as sysdba`

> 切换用户

`CONN scott/scott [AS SYSDBA]`

## 查看用户状态/解锁用户/修改密码

> 查看用户状态：

`SELECT username,account_status FROM dba_users;`

> 解锁用户

```sql
-- 解锁用户的同时也是修改密码
ALTER USER scott IDENTIFIED BY $password;
```

## sqlplus保存设置

-- 每行显示160个字符

`SET LENESIZE 160`

-- 每页显示100行

`SET PAGESIZE 100`

把这些语句写到一下文件后就能保存配置 

> $ORACLE_HOME/sqlplus/admin/glogin.sql

## execute sql script

`@$filename[.sql]`

如果不是sql后缀的文件，则需要加上后缀名

HOST语句可以执行系统命令例如 `HOST ls`

假如当前目录下有个a.sql的文件, `ed a` 命令会用记事本notepad编辑该文件