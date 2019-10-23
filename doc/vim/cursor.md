# vim cursor(光标移动)

一些查找、选取相关的放在其他章节介绍

## 行内光标移动

<pre>
w(W) - 向右跳至词首(词中可含標點)
b(B) - 向左跳至词首(词中可含標點)
e(E) - 向右跳至词尾(词中可含標點)
</pre>

## 大范围内移动

<pre>
g; - to last edit
g, - to previous edit
% - 调到匹配的标签或括号，如div会调到该div的关闭标签

    haha haha
0/$ - Home/End
| - 
^/_ - 行首第一个非空字符
gg - Ctrl+Home
G - Ctrl+End

Ctrl+f/b - pgup/pgdn
{} - 上/下一个段落 # vim的段落以一个或多个空行区分
() - 上/下一个段落，与花括号的区别像w和W的区别一样

\# 较少使用
- -> up
H - move to top of screen
M - move to middle of screen
L - move to bottom of screen
</pre>

### 画面移动

!> 如果安装了MRU插件，Ctrl+E变成打开Most Recents files

Ctrl+e/y - 上/下滚
zz - 把所在行移动画面中央  
zt/zb - 把当前行移动画面最上/最下

## terminal的光标移动
    
!> mac通过Alt+左右实现按单词左右跳，而win系统是Ctrl+左右

<pre>
cmd+n - Open new terminal window
Ctrl+l - same as clear
Ctrl+f/b - jump Forward/Backward by char
Alt+f/b - jump Forward/Backward by word
Alt+d - delete Forward by word
Ctrl+k - delete from cursor to end
Ctrl+a/e - Home/End
</pre>

> Mac下Alt+字母是希腊字母，Terminal中可设置use option as meta key

可搜索 "How to disable typing special characters when pressing option key" 找解决方案







## 较少使用

### 

> [!NOTE|label:弃用理由]
> 难按，功能上可被 I/A 或 F/f+char替代