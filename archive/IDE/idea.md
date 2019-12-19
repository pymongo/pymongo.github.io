# [idea/jetbrains全家桶通用技巧](archive/IDE/idea)

## ideaVim

新版的ideaVim真香~，使用与vim一样的配置文件，还能用vim插件

0.54版的ideaVim在keymap里只有3个快捷键设置项，有用的是vim emulator(开关vim快捷键)

vim其余设置其余的在`~/.ideavimrc`，注意大部分`.vimrc`的设置都不能用

<i class="fa fa-hashtag mytitle"></i>
vim emulator

通过find action找到**vim emulator**的设置项，决定vim和idea冲突的快捷键使用vim还是IDEA的

按照Mac的习惯我把 `Ctrl+P/N/F/B` 指定使用IDE的上下左右

## 代码间跳动

<i class="fa fa-hashtag mytitle"></i>
HTML标签/代码块 open/end之间跳动

<kbd>cmd</kbd>+<kbd>alt</kbd>+ <kbd>[</kbd> / <kbd></kbd>

> cmd+alt+[

<i class="fa fa-hashtag mytitle"></i>
在最近navigate的两处代码处跳动

如cmd+b找到方法的定义处，然后cmd+alt+左 返回

<i class="fa fa-hashtag mytitle"></i>
复制当前行

cmd+d

<i class="fa fa-hashtag mytitle"></i>
删除当前行

cmd+Backspace

<i class="fa fa-hashtag mytitle"></i>
选中当前变量名，并在所有出处放上光标

## 打开/关闭文件

不好用的搜索文件：cmd+1切换侧边栏，然后通过输入关键字查找文件

找到文件之后按Esc将光标退回editor，缺点是只能查找当前目录下的文件

> [!NOTE|label:两下￿￿shift]
> 按两下<kbd>Shift</kbd> 和vscode一样好用的查找输入框

找到并打开文件后可以点击导航栏的轮胎按钮定位到侧边栏中文件所在处

> [!TIP]
> 双击Shift还能在DataGrip中搜索字段名呢

cmd+Alt+O, cmd+O搜索类/字段等

DataGrip中cmd+Alt+O能搜索表的字段名，不过不能区分表名

## 错误处理

`F2`跳到下个错误，`Alt+Enter`列出解决错误的办法
