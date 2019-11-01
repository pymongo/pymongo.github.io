# [admin项目启动时遇到的各种错误](2019/11/admin-env)

## 软件版本

### 查看ruby版本

> cat .ruby-version

### 查看bundle版本

> tail Gemfile.lock

## 配置文件

### yml文件

开发服务器的配置只需要三个yml  Application,secret,database

### config/application.yml

修改 REDIS_URL 填上正确的redis地址

## 数据库迁移

执行数据库migrate之后才能启动rails服务器

### 数据库非utf编码导致中文报错

查看所有数据库的编码:

> SELECT schema_name,default_character_set_name FROM information_schema.SCHEMATA;

创建一个utf8的数据库

> CREATE DATABASE mydb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

## members

### 创建一个新的manager

必要字段: email,password,role_id,is_otp_binded

role_id=1说明是超级管理员, is_otp_binded=0表示登录不需要谷歌验证码

<!-- tabs:start -->

#### ** Create **

> Manager.create(email: "w@w.w", password: "adsfgh", role_id: 1, is_otp_binded: 0)

#### ** Read **

> Manager.find_by_email("w@w.w")

#### ** Update **

> Manager.find_by_email("w@w.w").update(phone: 13241234123) 

#### ** delete **

> Manager.find(16).destroy

<!-- tabs:end -->

