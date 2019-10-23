# mac init(配置等)

公司给我配的mbp到了，记录下配置开发环境的过程

## 系统app设置

### appstore and softwareUpdate

首先断网下把mac的更新给关了，我这台mbp是10.14的，有的10.13的软件都用不了😭

### finder设置

把finder sidebar没用的项去掉，view选项里把show path bar开了

### terminal设置

主题改为pro，字体大小改为16，Use Option As Metakey

## 启用root用户并创建workspace文件夹

[HowtoGeek的启用root用户教程](https://www.howtogeek.com/howto/35132/how-to-enable-the-root-user-in-mac-os-x/)

因为 /workspace  比 ~/workspace 容易敲，但是在非用户文件夹内没权限啊

第一次用sudo创建好文件夹好后，用chmod 777 开放全部权限，以后在workspace下面读写就不用sudo了

## cli工具与禁用更新

### gcc/cli_tools

> xcode-select --install

直接输入gcc也能自动安装，不过我不知道为什么gcc安装失败了

一开始就该用xcode的这个命令安装命令行工具(gcc等)

不幸的是安装cli工具时好像调用的appStore的检查更新功能，所以出现了提示系统更新的烦人信息

### disable systemPreference badge icon

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


## brew

### [Alias].bash_profile

```bash
alias v=vim
alias caps="hidutil property --set '{\"UserKeyMapping\":[{\"HIDKeyboardModifierMappingSrc\":0x700000039,\"HIDKeyboardModifierMappingDst\":0x70000002A}]}'"
alias ms="mysql -u root --password=123456"
alias pyser="python3 -m http.server 80"
alias docser="docsify serve . --open --port=80"
```


## brew install

- brew install python3
- brew cask install squirrel(rime IME, need logout to finish install)

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

## ruby

```bash
brew install rbenv # 注意rbenv不能与rvm共存
# 在.bash_profile里加入上
eval "$(rbenv init -)"
rbenv install 2.5.0
rbenv global 2.5.0
rbenv versions
```

## vim

[大师的配置教程](http://www.imooc.com/article/13269)

## Mysql

```bash
brew install mysql@5.7
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"
# 重启terminal
mysql_secure_installtion # 设置初始密码
```

最后别忘了用brew pin把rbenv mysql@5.7 nvm给固定住不再让他更新