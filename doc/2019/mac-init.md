# mac init(配置等)

公司给我配的mbp到了，记录下配置开发环境的过程

## 系统app设置

### appstore and softwareUpdate

首先断网下把mac的更新给关了，我这台mbp是10.14的，有的10.13的软件都用不了😭

### finder设置

把finder sidebar没用的项去掉，view选项里把show path bar开了

### terminal设置

主题改为pro，字体大小改为16，Use Option As Metakey

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


### brew install python3

