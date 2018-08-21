## 安装Oracle

注册个Oracle的账户，去到database下载页面

<details>
    <summary>我的Oracle账号</summary>
    <p>763205658@qq.com</p>
    <p>Asd12344321</p>
</details>

最新版的oracle只支持Linux64位和Sun公司自家系统

是不是说明只用一个11g或12c版本能吃到老？

[Oracle 11g 的安装及配置详解](https://www.cnblogs.com/dmego/p/6353641.html)

## hr账户及表的安装与导入

根据安装Oracle的位置，先设一个环境变量，以便减少路径的输入

`%ORACLE_HOME% = C:\Users\w\oracleDb\product\11.2.0\dbhome_1`

<a href="/drive/hr-oracle.zip">下载hr表</a> 解压到 %ORACLE_HOME%\demo\schema\human_resources

建议直接在human_resources文件夹内开启sqlplus登入sys账户，

执行`SQL>@hr_main`，注意输入路径时要用正斜杠

接着要输入5个参数，分别是 hr users temp oracle

最后一个参数 `%ORACLE_HOME%/demo/schema/log/` 末尾一个斜杠别漏了

我输入完成后第五个参数提示错误，不过不影响使用

> 测试hr账户

先切换到hr账户，密码也是hr `CONN hr/hr`

`SELECT * FROM tab;` 或 `SELECT table_name FROM user_tables;`

hr用户下一共有7个表，说明安装成功

## PL/SQL

PL/SQL是一个 第三方 Oracle客户端

我觉得好处是 上面代码下面输出，按快捷键运行上面的SQL语句

PL/SQL的输出非常好看，也提供便利的GUI操作修改数据库

左侧栏列出了tables、index、view等Oracle objects

## Oracle的服务进程

由于Oracle服务很占内存，所以不用时可以停掉

services.msc的服务管理界面中Manual的意思是手动

Oracle最重要的两个服务

监听服务：OracleOraDb11g_home1TNSListener：

程序操作数据库或用于remote client连接

数据库实例服务：OracleServiceORACLE

其中ORACLE是配置的数据库名称(严格来说是SID名称)

以下是Oracle服务无法正常运行的常见错误

!> 不要用优化大师/CCleaner之类的清理注册表，可能误删Oracle

!> 不要修改计算机的hostname

## 启动/关闭数据库

sys用户下，关闭数据库

`SHUTDOWN IMMEDIATE;`

启动数据库: `STARTUP`

