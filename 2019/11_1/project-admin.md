# [admin项目的配置与工作](2019/11_2/project-admin)

记录11月1日第一次参与后台管理项目过程中,环境配置的排错,任务/需求的实现等过

## admin是什么

www项目是普通用户的前端页面,cms项目是帮助文档及用户社区,base-api项目是给www提供API

那么后台管理就是网站管理员用户使用的,同时所有数据库的迁移都在里面,

可以在后台管理里给cms发布或修改新文章,也可以修改www项目的首页轮播图等

后台管理是这几个项目中最复杂的,提交次数也是最多的

## ruby版本和gem版本

.ruby-version记录了rvm设置的local_directory_ruby_version

Gemfile.lock文件的最后一行记录了

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

~~CREATE DATABASE mydb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;~~~

!> 必须用rake db:create保证数据库是utf-8

## 管理员表的CRUD

必要字段: email,password,role_id,is_otp_binded

role_id=1说明是超级管理员, is_otp_binded=0表示登录不需要谷歌验证码

<!-- tabs:start -->

#### ** Create **

> Manager.create(email: "w@w.w", password: "adsfgh", role_id: 1, is_otp_binded: 0)

#### ** Read **

> Manager.find_by_email("w@w.w")

#### ** Update **

> Manager.find_by_email("w@w.w").update(phone: 13241234123)

OR

```ruby
a = Manager.find(18)
a.password = "ffffjjjj"
a.save!
```

#### ** Delete **

> Manager.find(16).destroy

<!-- tabs:end -->

## 需求1:members的详情页面的修改

### 找到members页面的controller

> find . -name "members"

./app/views/private/members

显然这只是个views,不过通过views内按Ctrl+c跳转到controller的定义处

经过分析发现只需要修改show页面(详情页面)的数据显示,很简单

### 找到“上次登录时间”相关的字段

通过manager表可知上次登录时间的字段是 last_sign_in_at

于是就想到在多个表中搜索这个字段

```sql
SELECT DISTINCT TABLE_NAME, COLUMN_NAME  
FROM INFORMATION_SCHEMA.COLUMNS  
WHERE column_name LIKE 'employee%'  
AND TABLE_SCHEMA='YourDatabase'
SELECT * FROM information_schema.columns WHERE column_name = 'column_name';
--OR
```

## 任务2:添加机器人页面

机器人具体是什么先不用管,先把任务的页面及数据库原型图做好

### 顶部下拉菜单栏添加机器人按钮

首先通过grep命令找下顶部菜单栏在哪一个view里面

> grep 随便一个下拉菜单子项 . -r

```
./app/views/shared/_customer_service_menu.html.erb:          <span>随便一个下拉菜单子项</span>
./config/locales/zh.yml:    digital_urrency_transaction: 随便一个下拉菜单子项
```

第一个查询结果是在views中下划线开头的 **partials** 文件

第二个查询结果是的文件位置也很重要,以后添加国际化俄语支持需要

进去文件后发现菜单的选项**特别少**,根据文件名customer_service_menu可知这个应该是普通用户专用的菜单

那就顺藤摸瓜往下找应该能找到管理员专用的页面

### 给robot表添加约束/验证

```ruby
  validates :interval_of_hook, length: { in: 1..60 }
  validates :interval_of_sleep, length: { in: 1..60 }
  validates :status, inclusion: { in: %w(ok error),
    message: "staus must be ok or error" }
```

### superclass mismatch for class RobotsController

解决方案: 给controller外面包一层

### Model验证逻辑问题

关于robot数据验证的逻辑我放在这篇文章中介绍[rails数据验证](2019/11_2/validates)

## 翻译过程中的小问题

### 通过raw在erb文件中插入html代码

不加raw的话 没有转义html的br标签:

后记：后来通过Unicode调用font-awesome图表时，就必须通过raw把 **&#x**开头的Unicode转为html

像input标签的的文本藏在value属性里，只能通过unicode的办法显示图表
