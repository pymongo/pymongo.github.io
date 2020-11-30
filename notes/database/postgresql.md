# postgres note

brew安装完pg以后，默认会创建一个跟系统登录用户名一样的pg用户`brew services postgresql restart`去启动服务器

可以先不创建pg的super user，先用`psql --list`查看有哪些数据库(类似MySQL show databases)，然后用`psql postgres`连接pg数据库

在psql的console里，可以通过这个API`select current_database();`查看当前连接的数据库

pg必须要求连上数据库后才能进psql，进去以后可以用 \c或\connect 命令切换数据库

\dt = show tables, \d+或\d = desc/describle/.schema(SQLite)

dx命令可以检查已安装的插件，以此排查插件是否安装上的问题

## Linux postgres初始化

1. su - postgres
2. psql
3. CREATE USER username WITH PASSWORD 'password';
4. ALTER ROLE username WITH CREATEDB(or SUPERUSER); 

## mac postgres初始化

mac10.14.6系统下brew安装的postgres12.2一直连不上，

于是只好使用Postgres.app了。嘿嘿，不用的时候把App关掉就好了，还能节约内存，不像MySQL一直在后台占用内存

卸载了brew的postgres之后要重启才能正常使用。[将psql添加到PATH的方法](https://postgresapp.com/documentation/cli-tools.html)

1. CREATE USER username WITH PASSWORD 'password';
2. ALTER ROLE username WITH CREATEDB(or SUPERUSER); 

## 开发环境运行pg项目的错误排查

```
error: failed to connect to database: role "postgres" does not exist
115 | /         sqlx::query_as!(
116 | |             IgbMediaMeta,
117 | |             "UPDATE igb_media_meta.timestamp"
```

> createuser postgres -s

接着pg报错不支持create_hypertable函数，同事告知这是timescale的函数，看来我插件没安装上

同事建议我直接照着READAME上的docker去撸环境，再用pg的dx命令检查插件是否安装成功

结果用了docker后再报另一个错，字段missing，于是连进docker的pg数据库看看，字段都在啊

最终发现Bug出在.env文件配置的数据库密码是错的，由于SQLX的编译时SQL语句检查用的是功能较弱的const fn，

可能docker的pg密码错误后转而连brew的pg，但是我brew的pg没装timescale所以有的迁移文件没有跑全

sqlx的compile-time sql check用的是CTFE技术(sqlx用的是describe/explain语句检查是否报错，不插入任何数据，如果有bind就传相应类型的default值)

至于brew安装的pg为什么没有timescale的问题也找到了，官方配置插件的那篇文章看完就解决了

## timescaledb插件的安装

不要只看官方Installing的文档，还要看完Setting up TimescaleDb这篇文章

## postgres没有UPDATE/DELETE LIMIT 1的语句

postgres只有select才能搭配limit子句

## timescaledb

### first/last API

> select last(media_count,created_at) from igb_user;

first/last(normal_field, timestamp_field)

## 配置文件和log

### mac

配置文件路径: /usr/local/var/postgres/postgresql.conf

log路径: tail -f /usr/local/var/log/postgres.log
