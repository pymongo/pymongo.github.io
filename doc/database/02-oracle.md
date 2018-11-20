# Oracle安装/OEM/第三方工具

Tags: [数据库](#)

首发于: 18-09-20 最后修改于: 18-09-20

## 安装Oracle

注册个Oracle的账户，才能去Oracle官网下载Oracle数据库

[Oracle 11g 的安装过程](https://www.cnblogs.com/dmego/p/6353641.html)

如果不想安装Oracle, 登陆Oracle账号用 livesql.oracle.com 也是可以的

livesql.oracle.com建议用Firefox浏览器, 我在chrome上登陆了好几次都错误

## 对比MySQL安装

MySQL安装完后, 需要运行mysqld, 这是MySQL数据库的服务进程

类似ssh服务的服务进程是sshd, mongoDB安装完后也是要手动启动服务

而Oracle的服务进程是自动启动的, 只需用sqlplus从client连接

## Oracle的服务进程

由于Oracle服务很占内存，所以不用时可以停掉

services.msc的服务管理界面中Manual的意思是手动

Oracle最重要的两个服务

监听服务：OracleOraDb11g_home1TNSListener：

程序操作数据库或用于remote client连接

数据库实例服务：OracleServiceORACLE

其中ORACLE是配置的数据库名称(严格来说是SID名称)

以下是Oracle服务无法正常运行的常见错误

- 优化大师之类的清理误删Oracle注册表
- 不要修改计算机的hostname

## OEM简介

OEM(Oracle Enterprise Manager)是Oracle数据库的Web端管理软件

网址是:[https://localhost:1158/em](https://localhost:1158/em)
开发者一般用sqlplus, OEM是给DBM用的

注意只能用https协议访问，由于无SSL证书，需要浏览器单独允许

<img src="/img/database/oracle-https-localhost1158.png">

其它账户未授权下，只能用sys账户管理员身份登陆

> 在OEM上查看数据

从OEM主页进入到scheme页面->Tables

<img src="/img/database/oem-tables.png">

选中一个表, 在右上角的Action选上View data

Oracle给出了查询数据相应的SQL语句

<img src="/img/database/oem-departments-data.png">

OEM这样图形化查询/修改数据库的软件有点像Django的后台管理

## PL/SQL

PL/SQL是一个 第三方 Oracle客户端

我觉得好处是 上面代码下面输出，按快捷键运行上面的SQL语句

<img src="/img/database/plsql.png">

**相关文章**

<a href="/doc/sqlplus.md">sqlplus</a>