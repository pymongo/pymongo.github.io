# [mac init(配置等)](2019/10/mac-init)

相关文章 - [禁用option/alt键的特殊符号](/2019/11_2/ukelele/disable_alt_symbol_ukelele)

公司给我配的mbp到了，记录下配置开发环境的过程

## 系统app设置

首先断网下把mac的更新给关了，我这台mbp是10.14的，有的10.13的软件都用不了😭

finder设置: 把finder sidebar没用的项去掉，view选项里把show path bar开了

### emoji picker

Command+Control+Space: 打开emoji picker😃

### terminal设置

主题改为pro，字体大小改为16，**Use Option As Metakey**

### ~~启用root用户并~~创建workspace文件夹

[HowtoGeek的启用root用户教程](https://www.howtogeek.com/howto/35132/how-to-enable-the-root-user-in-mac-os-x/)

因为 /workspace  比 ~/workspace 容易敲，但是在非用户文件夹内没权限啊

所以先用sudo创建好文件夹后，chmod 777开权限，以后在workspace下面读写就不用sudo了

TODO:好像没有必要启用root

### gcc/cli_tools

> xcode-select --install

直接输入gcc也能自动安装，不过我不知道为什么gcc安装失败了

一开始就该用xcode的这个命令安装命令行工具(gcc等)

不幸的是安装cli工具时好像调用的appStore的检查更新功能，所以出现了提示系统更新的烦人信息

### 禁用系统更新

!> APP右上角的红色小数字通知叫「badge alert」 

为了考虑开发环境稳定性，不考虑更新系统。

而且10.15非全新安装的有两个[苹果官方承认](https://support.apple.com/en-in/HT210650)的缺陷：1.无法在根目录创建文件 2.个人文件被挪到另一个地方

现在系统设置的图标上面有红色数字1的恼人显示，英文叫red badge alert

> defaults write com.apple.systempreferences AttentionPrefBundleIDs 0

> killall Dock

但这个不是最有效的方法，根本上停止更新可通过ignore

### ignore Update

> [!NOTE|label:ignoreCatalinaUpdate]
> sudo softwareupdate --ignore "macOS Catalina"

> sudo softwareupdate --ignore "macOS 10.14.6 Update"

简单来说就是把更新的【名字】放进ignore里面

删除所有的ignore

> [!NOTE|label:删除所有的ignore]
> sudo softwareupdate --reset-ignored

## 安装APP

- GoogleChrome
- ExpressVPN
- 任意shadowsocks客户端(如GoAgentX)
- vscode
- brew install python3
- ~~brew cask install squirrel(rime IME)~~

## Node.js

brew install nvm完后在.bash_profile加入以下三行

```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
```
接下来就安装项目所需的node版本

nvm install v10.16.0

npm install -g @vue/cli

### npm之愉快的阅读离线文档

除了vue我还要安装两个npm的全局包：

- docsify(用于我个人博客及简单热重载服务器)
- gitbook

然后就能git clone一些技术文档，在本地启动服务器后离线阅读文档(如做飞机时)

更多相关介绍请看[同时热重载(livereload)多个网页]这篇文章(2019/11_2/multi-livereload.md)

## ruby

```bash
brew install rbenv # 注意rbenv不能与rvm共存
# 在.bash_profile里加入上
eval "$(rbenv init -)"
rbenv install 2.5.0
rbenv global 2.5.0
rbenv versions
```

### rails版本5.2.3

最初我没指定版本结果安装了6.X的rails，没有安装项目需要的5.2.3

卸载rails的指令如下，需要两步

1. gem uninstall rails
2. gem uninstall railties

最后 gem install rails -v 5.2.3

## vim配置

[大师的配置教程](http://www.imooc.com/article/13269)

TODO：补充我的个人偏好设置

## mysql5.7.27

网上已经找不到这个27的安装包，Oracle只给出了5.7.28的，所以还需自己保存一份以后项目用

鉴于brew install mysql@5.7导致gem各种找不到mysql而报错，所以还是用Oracle的安装包

[mysql安装配置请看这个教程](http://dxisn.com/blog/posts/macos-mysql-dmg)

## ~~Mysql@5.7安装~~

```bash
brew install mysql@5.7
# 将mysql的bin文件夹加到环境变量PATH
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"
# 重启terminal
mysql_secure_installtion # 设置初始密码
brew services start mysql # 设置开机启动mysql
```

### ~~gem install mysql报错~~

首先可以通过brew info mysql查看mysql的依赖，发现有两个没安装可能会影响gem安装mysql

> brew install openssl cmake

由于我不是安装最新版的mysql，导致gem找不到mysql的路径然后报错

!> gem install mysql2 -- --with-mysql-dir=/usr/local/opt/mysql@5.7/

## .bash_profile

最后别忘了用brew pin把rbenv、mysql@5.7、nvm忽略这三个项目SDK的更新，日后想要更新可以用unpin

!> 用brew list --pinned检查下三个SDK是否锁定版本 

全部软件安装完毕后我的bash配置如下

```bash
alias v=vim                                                                     
alias caps="hidutil property --set '{\"UserKeyMapping\":[{\"HIDKeyboardModifierM
alias ms="mysql -u root --password=asdf"
alias pyser="python3 -m http.server"
alias docser="docsify serve . -p 3999 -P 35700 --open"
alias gitbookser="gitbook --lrport 35710 --port 4001 serve"
alias gitpushblog="git add . && git commit -m 'add/edit posts' && git push"

export NVM_DIR="$HOME/.nvm"
[ -s "/usr/local/opt/nvm/nvm.sh" ] && . "/usr/local/opt/nvm/nvm.sh"  # This load
[ -s "/usr/local/opt/nvm/etc/bash_completion" ] && . "/usr/local/opt/nvm/etc/bas

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

export PATH=$PATH:/usr/local/mysql/bin
```