## OEM-localhost:1158

安装完Oracle后一直很纳闷，明明安装的是desktop应该有图形化操作界面啊

怎么就一个sqlplus命令行工具，为了跨平台+remote

OEM(Oracle Enterprise Manager)是个本地网页

[https://localhost:1158/em](https://localhost:1158/em)

只能用https协议访问，由于无SSL证书，chrome可以单独允许一次，Firefox可以把它添加到例外

<img src="/img/oracle/Oracle-https-localhost1158.png">

其它账户未授权下，只能用sys账户管理员身份登陆

登进去后看到很酷炫的dashboard用于监控数据库各种信息

## 在OEM上查看数据

从OEM主页进入到scheme页面->Tables

<img src="/img/oracle/oem-tables.png">

我们用hr的departments表(因为数据量较少)

点进departments表后可以看到 各字段的数据类型、索引表等

不过我关心的数据，在右上角的Action选上View data

<img src="/img/oracle/oem-view-data.png">

非常高兴地看到Oracle给出了相应的SQL语句

<img src="/img/oracle/oem-departments-data.png">