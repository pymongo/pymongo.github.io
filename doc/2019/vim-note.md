# vim操作

## vim通用
「:! 」 - 临时执行shell命令,如:! touch p.py
Ctrl+z - 暂时退出vim (推荐用小指指腹按Ctrl)
fg - 回到vim

. - 重复上一个操作

<pre></pre>
<pre>

Ctrl+f/b - pgup/pgdn
g; - to last edit
0 - Home
$ - End
gg - Ctrl+Home
G - Ctrl+End
W - 向右跳至词首 (词中可含標點)
e - 向右跳至词尾
E - 向右跳至词尾 (词中可含標點)
b - 向左跳至词尾
{} - 上/下一个段落
H - move to top of screen
M - move to middle of screen
L - move to bottom of screen

如果一个长行被wrap成两行，只能通过gj/gk在“两行”间上下移动

</pre>

## vim.insert_mode
<pre>
v - vision mode
V - select line vision mode
x/X - Delete/Backspace
s - 右删除一个字进入insert mode
i - insert before the cursor
I - insert at the beginning of the line
a - insert after the cursor
A - insert at the end of the line
o - append a new line below the current line
O - append a new line above the current line
ea - insert at the end of the word
Ctrl+O - 使下一个按键临时进入非插入模式后，又回到插入模式
Ctrl+[ OR Ese - 退出insert mode
</pre>


### vim.分屏
<pre>
「,t」OR「:NERDTree」 - sidebar file explorer
,q - close window(custom setting)
:MRU - recent files
:vs/sp file - 左右、上下分屏
:e file - open file
</pre>

## find/replace

### find

<pre>
查找汇总
f&lt;char> - find next char in current line 
*/# - find current word
n/N - find next/previous
N/n - find next in # and ?
</pre>

> [!NOTE]
> 「*」find/highlight current word

「#」find like ? . N is next

n/N - find next/previous

!> 如果用【?/#】搜寻，小写n表示寻找前一个（刚好相反）

> :set nohlsearch # 取消高亮

---

> [!TIP]
> /foo\c # 大小写不敏感查找

> :s/p/h1 # replace next p to h1 in current line

> :%s/p/h1 # replace all in current line

> :%s/p/h1/g # replace all in global

## NERDTree
<pre>
R - refresh file explorer
Ctrl+,hjkl - move cursor between window
g/i - 垂直/水平分割打开文件
x - 合拢选中结点的父目录
X - 递归 合拢选中结点下的所有目录
p - cd ..
p - cd ../..
J/K - 调到当前目录最上/最下的文件
</pre>

## terminal

!> mac通过Alt+左右实现按单词左右跳，而win系统是Ctrl+左右

<pre>
cmd+n - Open new terminal window
Ctrl+l - same as clear
Alt+f/b - jump Forward/Backward by word
Ctrl+f/b - jump Forward/Backward by char
Alt+d - delete Forward by word
Ctrl+k - delete from cursor to end
Ctrl+a/e - Home/End
</pre>