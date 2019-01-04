# Oracle安装/OEM/第三方工具

首发于: 18-09-20 最后修改于: 19-01-03

## Oracle运行环境与服务进程

- [Oracle 11g 的安装过程](https://www.cnblogs.com/dmego/p/6353641.html)

- 如果不想安装Oracle, 用 livesql.oracle.com

MySQL安装完后, 需要运行mysqld, 这是MySQL数据库的服务进程

Oracle的服务进程是开机自动启动的, 而且很占内存

## OEM简介

OEM(Oracle Enterprise Manager)是Oracle数据库的Web端管理软件

网址是:[https://localhost:1158/em](https://localhost:1158/em)

注意只能用https协议访问，由于无SSL证书，需要浏览器单独允许

![01-oem-localhost1158](01-oem-localhost1158.png "01-oem-localhost1158")

其它账户未授权下，只能用sys账户管理员身份登陆

> 在OEM上查看数据

从OEM主页进入到scheme页面->Tables

![02-oem-tables](02-oem-tables.png "02-oem-tables")

选中一个表, 在右上角的Action选上View data

Oracle给出了查询数据相应的SQL语句

![03-oem-departments-data](03-oem-departments-data.png "03-oem-departments-data")

OEM这样图形化查询/修改数据库的软件有点像Django的后台管理

## sqlplus与idea的数据库工具

初学者可能需要sqlplus熟练命令, 但是想要验证一个多行的sql语句, sqlplus真不如idea的数据库工具方便。idea更换不同数据库只需安装相应的jcdb驱动即可, 所有数据库都用同一个界面去操作, 降低了学习成本。本文简单介绍下sqlplus的常用命令


## sqlplus连接/切换用户

> 连接用户

`sqlplus scott/scott` 或 `sqlplus / as sysdba`

> 切换用户

`CONN scott/scott [AS SYSDBA]`

> 查看用户状态：

`SELECT username,account_status FROM dba_users;`

> 解锁用户

```sql
-- 解锁用户的同时也修改密码
ALTER USER scott IDENTIFIED BY $password;
```

## sqlplus保存设置

-- 每行显示160个字符

`SET LENESIZE 160`

-- 每页显示100行

`SET PAGESIZE 100`

把这些语句写到一下文件后就能保存配置 

> $ORACLE_HOME/sqlplus/admin/glogin.sql

## sqlplus execute .sql file

`@$filename[.sql]`

如果不是sql后缀的文件，则需要加上后缀名

HOST语句可以执行系统命令例如 `HOST ls`

假如当前目录下有个a.sql的文件, `ed a` 命令会用记事本notepad编辑该文件
