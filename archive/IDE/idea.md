# [idea/jetbrains全家桶通用技巧](archive/IDE/idea)

## cmd+Alt+O, cmd+O搜索类/字段等

DataGrip中cmd+Alt+O能搜索表的字段名，不过不能区分表名

## HTML标签/代码块 open/end之间跳动

<kbd>cmd</kbd>+<kbd>alt</kbd>+ <kbd>[</kbd> / <kbd></kbd>

> cmd+alt+[

## 打开/关闭文件

不好用的搜索文件：cmd+1切换侧边栏，然后通过输入关键字查找文件

找到文件之后按Esc将光标退回editor，缺点是只能查找当前目录下的文件

> [!NOTE|label:两下shift]
> 按两下<kbd>Shift</kbd> 和vscode一样好用的查找输入框

找到并打开文件后可以点击导航栏的轮胎按钮定位到侧边栏中文件所在处

> [!TIP]
> 双击Shift还能在DataGrip中搜索字段名呢

---

关闭当前文件：

默认的快捷键是Ctrl+F4相当不好用，肯定要改掉

## vim快捷键配置

有个见vim emulator的设置项，决定冲突的快捷键使用vim还是IDEA的

!> 不能用J,J退出编辑模式，因为idea不区分imap，nmap

- Ctrl+; 退出编辑模式

光标移动的快捷键建议绑定在editor action，而且Ctrl+F不好使

> [!DANGER|label:不好使的快捷键]
> Ctrl+H强制是退格, Ctrl+F改不了 
