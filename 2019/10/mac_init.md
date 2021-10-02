# [mac init(配置等)](/2019/10/mac_init.md)

相关文章 - [禁用option/alt键的特殊符号](/2019/11/ukelele/disable_alt_symbol_ukelele)

公司给我配的mbp到了，记录下配置开发环境的过程

## 系统app设置

### finder设置

把finder sidebar没用的项去掉，view选项里把show path bar开了

### terminal设置

主题改为pro，字体大小改为16，设置选项里`Use Option As Metakey`

### ~~启用root用户~~

sudo基本能解决99%需要root权限的场合，没必要启用root用户

### gcc/cli_tools

`sudo DevToolsSecurity -enable # Developer mode is now enabled`

> sudo mount -uw /	# 根目录挂载为可读写，否则无法在/usr/下建立文件，本修改重启前有效。

推荐看mac编译PHP等项目时找不到库文件的解决方法的[文章](https://zhile.io/2018/09/26/macOS-10.14-install-sdk-headers.html)

> xcode-select --install

建议直接安装Xcode，解决很多库和SDK找不到的问题，还可以直接跑一下同事的IOS代码

另外Xcode的更新是增量更新，所以更新大小11G硬盘空间25G都可能提示空间不足，这种情况建议直接卸载xcode重装也比全新下载的更新快

### [可选]禁用系统更新

!> APP右上角的红色小数字通知叫「badge alert」 

为了考虑开发环境稳定性，不考虑更新系统。

而且10.15非全新安装的有两个[苹果官方承认](https://support.apple.com/en-in/HT210650)的缺陷：1.无法在根目录创建文件 2.个人文件被挪到另一个地方

现在系统设置的图标上面有红色数字1的恼人显示，英文叫red badge alert

> defaults write com.apple.systempreferences AttentionPrefBundleIDs 0

#### ignore Update

> [!NOTE|label:ignoreCatalinaUpdate]
> sudo softwareupdate --ignore "macOS Catalina"

> sudo softwareupdate --ignore "macOS 10.14.6 Update"

简单来说就是把更新的【名字】放进ignore里面

删除所有的ignore

> [!NOTE|label:删除所有的ignore]
> sudo softwareupdate --reset-ignored

## 开发软件安装

对我而言rustup, vscode, IDEA是必备的

大部分公司配的电脑都是8G内存，不能同时开太多IDEA软件，所以用「vscode比较省内存」

### ~~vim配置~~

[大师的配置教程](http://www.imooc.com/article/13269)

TODO：补充我的个人偏好设置

### mysql5.7.27

网上已经找不到这个27的安装包，Oracle只给出了5.7.28的，所以还需自己保存一份以后项目用

鉴于brew install mysql@5.7导致gem各种找不到mysql而报错，所以还是用Oracle的安装包

[mysql安装配置请看这个教程](http://dxisn.com/blog/posts/macos-mysql-dmg)

#### ~~Mysql@5.7安装~~

```
brew install mysql@5.7
# 将mysql的bin文件夹加到环境变量PATH
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"
# 重启terminal
mysql_secure_instaltion # 设置初始密码
brew services start mysql # 设置开机启动mysql
```

#### ~~gem install mysql报错~~

首先可以通过brew info mysql查看mysql的依赖，发现有两个没安装可能会影响gem安装mysql

> brew install openssl cmake

由于我不是安装最新版的mysql，导致gem找不到mysql的路径然后报错

!> gem install mysql2 -- --with-mysql-dir=/usr/local/opt/mysql@5.7/

### .bash_profile

Update: mac 10.15以后系统默认的shell是zsh，在~/.zshrc上加上一行`source ~/.bash_profile`就可以让bash和zsh同时使用shell

---

## 题外话: mac一些有用的功能

Command+Control+Space: 打开emoji picker😃
