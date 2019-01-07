# Oracle的emp表迁移到sqlite

首发于: 18-09-23 最后修改于: 19-01-04

## 迁移需求

没有安装Oracle, 而很多教程都是用scott用户的emp表, 其实sqlite官方提供了一个唱片相关的数据库, 搜索SQLite Sample Database


## 迁移难点

Oracle与sqltie的语法不同, Oracle与sqlite数据类型不同

## 迁移方案论证

> 迁移方案一: Oracle在[github开源](https://github.com/oracle/dotnet-db-samples/blob/master/schemas/scott.sql)
的scott创建脚本

主要缺点: sqlite和oracle的sql语法差异很大, 很难修改

而且sqlite没有datetime类型, 没有to_date函数

> 迁移方案二: livesql.oracle.com官方创建脚本

我在Oracle安装/OEM/第三方工具一文中提到在线运行Oracle脚本的网站

这个livesql有点像Jupyter Notebook一样保存输入记录及相应输出结果

可读性比github的sql脚本强多了, [livesql相应笔记地址](https://livesql.oracle.com/apex/livesql/file/content_O5AEB2HE08PYEPTGCFLZU9YCV.html)

![01-livesql-demo](01-livesql-demo.png "01-livesql-demo")

看到这html-table格式的表格, 打开浏览器Dev Tools,

复制html源码, 随便找个"Online html table to csv", 转换成csv

事后我才发现这张表仅select了emp表几个字段, 所以数据不全

把方案一中github创建emp表代码粘贴方案二提到的livesql中, 自己加上`SELECT * FROM EMP;`

![02-livesql-csv](02-livesql-csv.png "02-livesql-csv")

## 查看/修改csv文件

用Excel查看/修改csv是最方便的, 不过Excel会把csv很大的数转为科学记数法

0开头的字符串却被Excel当成整数截掉开头的0, Excel会改变csv文件的数据类型

不建议用Excel修改csv数据, 有次我用Excel修改谷歌浏览器保存的密码, 几乎把我密码全毁了

用vscode/notepad这样文本形式编辑csv即可

## sqlite导入csv

[写的非常棒的sqlite导入csv教程](http://www.sqlitetutorial.net/sqlite-import-csv/)

sqlite导入csv分*两种*情况, 表已创建只导入csv的数据

或表未创建csv第一行作为各个字段名(就像pandas模块读取csv)

!> sqlite表创建后不得删除/修改字段

而且自动判断类型判别会产生歧义(比如把整数看作TEXT)

**强烈建议**先定义字段数据类型再导入数据

```sql
DROP TABLE IF EXISTS emp;
CREATE TABLE emp (...);
.mode csv -- 设为csv模式才能正确地导入
.import emp.csv
```

## NULL值处理

NULL值一般在csv中表示为空字符串, 在livesql导出中表示为" - "

emp员工信息表MGR字段(上司的员工编号)有一个记录是NULL(CEO没有上司)

验证下`SELECT COUNT(mgr) FROM emp WHERE mgr=NULL;`结果发现MGR列NULL值数为0

还是要把空字符串值""改为NULL

## 导出为sql脚本备份

`sqlite3 emp.db .dump > emp.sql`

其实只需要留一个csv数据文件, 不过想看看创建emp表的SQL语句
