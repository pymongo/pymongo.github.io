# [spring boot部署与体验](/2020/03/spring_boot_quickstart.md)

基于公司业务需求，最近我需要在一个用spring写的开源项目的基础上二次开发

这是我第一次接触spring框架，希望它能像Flask或Rails那样让我眼前一亮

## JAVA版本管理与切换

Linux有<var class="mark">update-alternatives</var>，mac的`jenv`就没那么好用

所以mac上被迫只安装一个jdk8，没法用jdk9以上的`jshell`交互环境(实践一些Java语法只能靠online jdk了)

在mac开发环境上不需要安装maven，用Intellij自带的maven就够了；在Ubuntu上先安装jdk8再安装maven

## nohup ... 2>1& &

maven install/package 编译出可执行文件后，通过nohup使之后台运行

`2>1&`的意思是把stdout也重定向输出到nohup.out中

至于如何关掉nohup，`jobs -l`不好使，一般用以下命令列出占用内存最大的进程再通过`kill -9`去删

以下命令可以列出内存占用最高的几个进程，方便关掉java的nohup进程

> ps aux --sort rss

## 创建spring boot项目

我看[这个视频](https://www.youtube.com/watch?v=vtPkZShrvXQ)入门spring

初始化spring项目可以在`start.spring.io`中进行，也可在Intellij中进行

`start.spring.io`创建spring项目的过程有点酷炫(像vultr)，但我还是喜欢在IDE中创建项目

NewProject -> SpringInitializr

[spring官方教程](https://spring.io/guides/gs/spring-boot/#initial)

DAO我以前做安卓SQLite时有所理解，但是spring的service有点难以理解

controller我理解是解析前端发送的请求，调用service来处理业务，再调用dao来实现数据库操作

还是rails方便，dao和model合二为一、service和controller合二为一

还有一种理解是service相当于项目的子系统

## spring添加一个路由

我仿照官网教程导入`org.springframework.web`包准备添加路由时一直报错，原来是我没导入spring的web组件

```xml
<dependency>
  <groupId>org.springframework</groupId>
  <artifactId>spring-web</artifactId>
</dependency>
```

嗯，感觉照着官网的教程把controller写好了，Ctrl+R运行... 刚出现spring的LOGO，进程就结束了

> process finished with exit code 1

网上找了下资料，我没有装tomcat服务器，需要一个HTTP服务器

```xml
<dependency>
  <groupId>org.springframework.boot</groupId>
  <artifactId>spring-boot-starter-web</artifactId>
</dependency>
```

<i class="fa fa-hashtag"></i>
修改HTTP服务器运行的端口号

application.properties: server.port=8080
