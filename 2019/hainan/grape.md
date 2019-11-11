# [grape接口服务器](2019/hainan/grape)

## grape是什么

grape是一个基于rack的REST-like APIs,可以通过[petstore.swagger.io](http://petstore.swagger.io/#/)可视化测试接口,

## 为什么要学grape

### 火币交易的数据都是socket二进制加密的

除了交易的接口数据需要加密,别的数据比如帮助文档不加密也无所谓

![火币网的ws数据加密](grape.png "火币网的ws数据加密")

友商MXC抹茶网的交易页面全是明文传输,信息很不安全

所以希望我们自己的交易所能通过websocket加密传输再由前端解密

### 学习理由1:grape对ws的支持很好

所以我们就要用grape编写ws或binary frame的接口

### 学习理由2:rails的性能不好,接口要脱离rails

## 🔔apache benchmark测试接口速度

ab命令全称是apache HTTP server benchmark

用于**测试**网页性能, 我们来比较下rails和rack的性能

rack是ruby最简单的HTTP服务器组件, 咱们来跑跑分看看

ab命令的语法格式:

> ab -n 100 -c 10 http://localhost:3000/wallets/1278

-n 表示总共有100个请求, -c 表示并发的请求数(concurrency)

ab的测试结果主要是看 Time per request: (mean, across all concurrent requests)

我们的rails的测试结果是平均8.4ms完成一个请求,接下来看看最轻量的rack速度如何

## 步骤1: 新建Gemfile并通过Gemfile安装rack

### 步骤1.1: 编辑Gemfile

```bash
# Gemfile 1st edit
source 'https://gems.ruby-china.com'
ruby '2.5.0'

gem "rack", "2.0.7"
```

### 步骤1.2: 通关Gemfile安装rack

```
bundle
bundle list
  * bundler (2.0.2)
  * rack (2.0.7)
```

### 步骤1.3: 初始化git并添加远程服务器

```
git init
git remote add origin https://github.com/daydayup-beijing/aoxiang_manager.git
git remote -v # check remote server
git add .
git commit -m "新建Gemfile并通过Gemfile安装rack"
git push
```

## 步骤2: 新建config.ru并启动服务器

```bash
# config.ru 1st edit
run Proc.new { |env| ['200', {'Content-Type' => 'text/html'}, ['hellow rack']] }  
```

> bundle exec rackup config.ru -p 3333

ab测试显示该接口平均0.7ms完成一个请求

```
git commit -m "添加了config.ru, 测试了rackup"
```

## 步骤3: 启动简易grape接口

[脱离Rails使用acticerecord - 大师的博客](http://siwei.me/blog/posts/origin_from_javaeye_533)

```bash
# Gemfile 2st edit
source 'https://gems.ruby-china.com'
ruby '2.5.0'

gem "rack", "2.0.7"
gem "grape", "1.2.4"
gem "mysql2", "0.5.2"
gem "activerecord", "6.0.0"
```

### 遇到的问题

> LoadError: cannot load such file -- app/models/order.rb

解决方案: app前面加个 ./

结果显示grape需要54ms才能完成一个带读取数据库的请求


## swagger

由于grape没有自带serve功能,所以网上的教程差异都很大

项目用的开发环境是ruby:2.6.1 bundle:2.0.2

!> rbenv安装一个新的ruby版本时需要重新安装bundle

> gem install bundler:2.0.2

1. cp config/database.yml.example config/database.yml
2. vim config/database.yml
3. bundle exec guard -d

## grape-swagger

在以下两个文件中实现了swagger的定义

- Gemfile,12:gem 'grape-swagger'
- app/api.rb,5:    add_swagger_documentation(

启动服务器后在

## constrant没找到/未初始化的问题

ruby的module名和文件夹名一定要对应上

对应关系为 module_name.**underscore** = folder_name
