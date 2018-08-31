## 连接

只打sqlplus进去后还要输入账户密码，不方便

`sqlplus hr/hr`

`sqlplus / as sysdba`

切换用户：

`CONN hr/hr [AS SYSDBA]`

## 查看用户状态/解锁用户/修改密码

> 查看用户状态：

```sql
SELECT username,
account_status
FROM dba_users;
```

> 解锁用户(不然没法使用)：

```sql
ALTER USER scott IDENTIFIED BY ${password};
```

## exec sql script

`@${filename}[.sql]`

如果不是sql后缀的文件，则需要加上后缀名

## edit file in sqlplus

假如当前目录下有个a.sql的文件

那么 `ed a` 命令会用记事本notepad编辑该文件

## sqlplus exec system command

加上HOST 前缀即可

例如 `HOST ls`

## 让sqlplus的输出更好看点

-- 每行显示字符

`SET LENESIZE 160`

-- 每页显示100行

`SET PAGESIZE 100`