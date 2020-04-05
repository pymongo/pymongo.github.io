# [Rust如何建立DATE/DECIMAL类型的映射](/2020/04/diesel_orm.md)

注意：本文一开始是用MySQL，后面改用PostgreSQL

Rust用diesel库建立ORM映射，我很好奇如何建立DATE和DECIMAL类型的映射

## 初始化数据库

首先要添加dotenv和diesel这两个库的依赖

```
dotenv = "0.15.0"
diesel = { version = "1.4.4", features = ["mysql"] }
```

如果之前没安装过diesel_cli，还需要安装下

> cargo install diesel_cli

在.env文件中添加DATABASE_URL的配置项:

> DATABASE_URL=mysql://username:password@localhost/actix_first

运行diesel setup，会自动创建好所需的数据库

!> 注意diesel setup会将所有的数据库迁移都执行一遍

### ubuntu:postgres初始化

1. su - postgres
2. psql
3. CREATE USER username WITH PASSWORD 'password';
4. ALTER ROLE username WITH CREATEDB(or SUPERUSER); 

### mac:postgres初始化

mac10.14.6系统下brew安装的postgres12.2一直连不上，

于是只好使用Postgres.app了。嘿嘿，不用的时候把App关掉就好了，还能节约内存，不像MySQL一直在后台占用内存

卸载了brew的postgres之后要重启才能正常使用。[将psql添加到PATH的方法](https://postgresapp.com/documentation/cli-tools.html)

1. CREATE USER username WITH PASSWORD 'password';
2. ALTER ROLE username WITH CREATEDB(or SUPERUSER); 

## 添加数据库迁移文件

> diesel migration generate create_users

会生成两个sql文件，手写建表的sql后， diesel migration run/redo 进行迁移