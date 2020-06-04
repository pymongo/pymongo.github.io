[归档 - 吴翱翔的博客](/)

[我的简历](/redirect/resume.html)

原始博客站点：[pymongo.github.io](https://pymongo.github.io)
镜像1：[wuaoxiang.github.io](https://wuaoxiang.github.io)
镜像2：[aoxiangwu.github.io](https://aoxiangwu.github.io)

## 我在开源社区上的贡献(PR)

### https://github.com/launchbadge/sqlx

sqlx 是Rust语言一款数据库工具，我参与了sqlx的MySQL相关文档的修正

- [PR#391](https://github.com/launchbadge/sqlx/pull/319) Fix a misspelling in MySQL types document

### actix/examples

actix/examples 是actix_web的样例代码仓库

- [PR#298](https://github.com/actix/examples/pull/298) 删掉了关闭服务器example中两个未使用的变量，避免内存浪费

### wildfirechat/android-chat

野火IM是一款仿微信的聊天软件，我参与了安卓端的开发

- [PR#330](https://github.com/wildfirechat/android-chat/pull/330) 将聊天消息RecyclerView仅用于UI预览下显示部分设为tools:text

### lukesampson/scoop

scoop是一款windows系统的包管理工具，类似mac的homebrew或Linux的apt-get

当时的scoop基本靠人工发现软件新版本，然后手动更新bucket文件，我参与更新了7zip/sqlite的版本

不过现在scoop通过爬虫脚本自动抓取软件的最新版本，基本不需要人工更新bucket文件了

- [pull#2945](https://github.com/lukesampson/scoop/pull/2945) 更新windows系统包管理器工具scoop中7zip的版本号

---

## Github老外常见英文缩写

公司没有code review，学习全靠开源社区(PR/issue/读源码)，

经过不断地学习我成功在actix项目组中贡献了自己的[PR](https://github.com/actix/examples/pull/298)😄

以下是github issue/PR中老外的comment中常见的英文单词缩写

- AKA: Also Known As
- FYI: For Your Information
- AFAICT: As Far As I Can Tell

## 高频英语单词

- retrieve: 恢复
- Boilerplate code: 样板代码
- middleware: 中间件
- Primitive type: 原始类型(例如Java的int等等)
- implicitly: 隐含地

## README常见短语

- In a nutshell: 简而言之

您好，我注意到【飞书】项目组最近在急招(有大量HC)，我想投递Rust相关的岗位，可是飞书只有「资深Rust工程师」的岗位，
而且招聘截止日期写的是6月30日。还有没有要求相对较低的Rust岗位(北京)

您好，我想投递Rust相关的岗位，地点北京，时间10月前

可是贵司大部分Rust相关的岗位都是「Rust工程师/C++工程师」
所以我除了Rust还要复习C++？我C++没有做过商业项目
我现在的学习计划是leetcode用Rust刷题，阅读Rust英文书籍

我注意到【飞书】项目组最近在急招(大量HC)，截止日期6月30日，投递飞书相关的Rust岗位会不会容易点？

## 常用的又没背下来的命令

- find ~ -iname '*.apk'
- lsof -i :8080
- fuser 80/tcp
- netstat -nlp | grep :80

## 技术术语缩写

[RPC](https://zhuanlan.zhihu.com/p/36427583): Remote Procedure Call

分布式系统中，调用远程服务器的某个类方法，比Restful API更高效 

## 名词缩写

我个人不喜欢变量命名中将单词缩写的习惯，不过有些缩写还是要记一下免得看不懂别人代码

- srv -> server
- conn -> connection

## 线程相关的英文单词

- Parallel or Consecutively(并发或连续，指的是rust单元测试test case的运行方式)

海南省经济状况的观察：

随着疫情原因外地旅客减少、哈罗电动车在海南的推广，如今的海南的道路上越来越少摩的司机了。

起步价2元月卡10元的哈罗电动车逐渐蚕食5元起步价的摩的司机。

由于海南地理原因，工业品运输往内地的成本很高，可能这是海南工厂特别少工业不发达的一个原因。
