# [cursor(光标移动)](archive/vim/cursor)

一些查找(如f+char)、选取相关的光标移动方法放在其他章节介绍

## 行内光标移动

<pre>
w(W) - 向右跳至词首(词中可含標點)
b(B) - 向左跳至词首(词中可含標點)
e(E) - 向右跳至词尾(词中可含標點)
0/$ - Home/End
| -  Home
^/_ - 行首第一个非空字符
</pre>

## 大范围内移动

<pre>
g; - to last edit
g, - to previous edit
% - 调到匹配的标签或括号，如div会调到该div的关闭标签

gg - Ctrl+Home
G - Ctrl+End

Ctrl+f/b - pgup/pgdn
{} - 上/下一个段落 # vim的段落以一个或多个空行区分
() - 上/下一个段落，与花括号的区别像w和W的区别一样

\# 较少使用
- - previous line's home
H - move to top of screen
M - move to middle of screen
L - move to bottom of screen
</pre>

### 画面移动

!> 如果安装了MRU插件，Ctrl+E变成打开Most Recents files

Ctrl+e/y - 上/下滚
zz - 把所在行移动画面中央  
zt/zb - 把当前行移动画面最上/最下

## terminal光标移动

> [!NOTE|label:Ctrl-PNBF上下左右]
> Mac系统全局快捷键：Ctrl+P/N.B/F - 上下左右

Mac还有一个常用的全局光标移动快捷键 Ctrl+a/e - Home/End

!> mac通过Alt+左右实现按单词左右跳，而win系统是Ctrl+左右


以下terminal快捷键在vim也能使用：
- ctrl+w - 向左删除一个单词(仅插入模式)
- ALt+f/b - 向前/后跳一个单词

!> Mac下Alt+字母是希腊字母，Terminal中可设置use option as meta key

可搜索 "How to disable typing special characters when pressing option key" 找解决方案

### 一些实用的terminal命令

Ctrl+k - delete Forward by word
Ctrl+Cmd+l - 清屏
