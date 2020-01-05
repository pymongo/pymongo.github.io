# [每月技术分享和codeReview_2020年1月](/2020/01_1/code_review.md)

## 解释持续集成

测试服务器有一个脚本，每隔5分钟运行所有单元测试，如果出现没通过的test case就报警

优点：多个人给项目提交代码时，一旦有人写错代码，也能快速发现错误

## Android app security features

[Android fundamental](https://developer.android.com/guide/components/fundamentals)

The Android operating system is a multi-user Linux system in which each app is a different user

By default, the system assigns each app a unique Linux user ID

(the ID is used only by the system and is unknown to the app). 

安卓进程相关

By default, every app runs in its own Linux process

Each process has its own virtual machine (VM), so an app's code runs in isolation from other apps

概况：安卓系统会给每个APP分配一个独有的Linux用户ID、一个独有的进程(VM)，一些独有访问权限的文件

但是，为了节约系统资源，如果signed with the same certificate的App间可以共享数据

## Android JobScheduler

App components一共四种，除了Activity还有Services(如音乐播放器)

、Broadcast receivers(消息推送?)、Content providers(SQLite之类，多个app共享数据)

除了Content providers，其它三都可以用Intent实现数据传递

## jenv管理Java版本

`jenv add $(/usr/libexec/java_home)`

`jenv versions`

`jenv add /Library/Java/JavaVirtualMachines/adoptopenjdk-8.jdk/Contents/Home/`

TODO jenv的实践经验
