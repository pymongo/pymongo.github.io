# [idea快捷键](2019/11/idea)

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

## cmd+Alt+O, cmd+O搜索类/字段等

DataGrip中cmd+Alt+O能搜索表的字段名，不过不能区分表名

## DataGrip

DataGrip可以cmd+o定位到表名后win+F12定位到特定字段

选中table,cmd+B: Open table in DDL(SQL语句版本)

cmd+alt+G: Open the SQL generator

## vim快捷键配置

!> 不能用J,J退出编辑模式，因为idea不区分imap，nmap

- Ctrl+; 退出编辑模式

光标移动的快捷键建议绑定在editor action，而且Ctrl+F不好使

> [!DANGER|label:不好使的快捷键]
> Ctrl+H强制是退格, Ctrl+F改不了 