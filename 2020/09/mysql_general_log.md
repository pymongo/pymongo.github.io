# [MySQL general log](/2020/09/mysql_general_log.md)

之前写sqlx和diesel的文章时提过Mysql general log，

最近在Linux上Debug一个sqlx的问题时，发现mysql的配置文件去设置general_log挺方便的

主要是通过命令行开关general_log不太方便，而且很容易莫名其妙地就关掉了

```
mysql> SHOW GLOBAL VARIABLES LIKE '%general%';
mysql> SET GLOBAL general_log = 'ON';
mysql> SET GLOBAL general_log_file = '/var/log/mysql_general_log.log';
```

后来我发现mac上就不想折腾怎么读取MySQL配置了，

Linux服务器上的mysql配置文件在，低版本MySQL改完后需要重启服务器`ststemctl restart mysql.servie`

> /etc/mysql/mysql.conf.d/mysqld.cnf

```
localhost:~ w$ mysql --help | grep my.cnf
                      order of preference, my.cnf, $MYSQL_TCP_PORT,
/etc/my.cnf /etc/mysql/my.cnf /usr/local/mysql/etc/my.cnf ~/.my.cnf 
```

