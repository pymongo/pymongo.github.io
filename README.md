[归档 - 吴翱翔的博客](/)

Contact me: os.popen@gmail.com

<!--
[我的简历](/redirect/resume.html)
原始博客站点：[pymongo.github.io](https://pymongo.github.io)
镜像1：[wuaoxiang.github.io](https://wuaoxiang.github.io)
镜像2：[aoxiangwu.github.io](https://aoxiangwu.github.io)
-->

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

## Github社区常见英文缩写

公司业务/项目代码通常是很简单的，要参与开源项目Application、Web Framework、Library等类型的开源项目去提升自我竞争力

经过不断地学习我成功在actix项目组中贡献了自己的[PR](https://github.com/actix/examples/pull/298)😄

以下是github issue/PR中老外的comment中常见的英文单词缩写

- AKA: Also Known As
- FYI: For Your Information
- AFAICT: As Far As I Can Tell
- LGTM: An acronym(首字母缩写) for "Looks Good To Me"
- In a nutshell: 简而言之

## 常用的又没背下来的linux command trick

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

---

## 未分类的笔记

### 生产服务器使用ssh-agent获取开发环境的github密钥去拉代码

为了安全考虑，生产服务器上的git配置是仅允许公钥进行拉代码

1. 将~/.ssh/id_rsa.pub中的公钥加到github账号设定的密钥部分
2. ~/.ssh/config下添加以下几行(因为用的是开发环境的SSH client，所以不用重启开发环境的sshd server)

```
Host *
	AddKeysToAgent yes
	UseKeychain yes
	IdentityFile ~/.ssh/id_rsa
```

3. `ssh-agent -s`启动开发环境的ssh-agent process
4. `ssh-add ~/.ssh/id_rsa`将密钥加到ssh-agent中

配置完上述操作后，即便ssh-agent没有开启，ssh -a时也会自动启动`/usr/bin/ssh-agent -l`
