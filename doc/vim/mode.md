# vim mode,macro

## vim通用
「:! 」 - 临时执行shell命令,如:! touch p.py
Ctrl+z - 暂时挂起vim (推荐用小指指腹按Ctrl)
fg - 回到vim
:wq、:x、ZZ - save and exit

## 格式化代码

== - auto format current line

>> and << 实现单行缩进调整

## marco and nmap

实现不进入插入模式实现插入空行，不能用p

方法一 :nmap oo o<Esc>k  
这样以后按oo自动在光标下插入一行

方法二 录制宏

1. qd	start recording to register d
2. ...	your complex series of commands
3. q	stop recording
4. @d	execute your macro
5. @@	execute previous macro 

## mode切换

<pre>
x/X - Delete/Backspace
s - 右删除一个字进入insert mode
S - 删除行并插入
i - insert before the cursor
I - insert at the beginning of the line
a - insert after the cursor
A - insert at the end of the line
o - append a new line below the current line
O - append a new line above the current line
r - replace char
R - replace mode
ea - insert at the end of the word
Ctrl+O - 使下一个按键临时进入非插入模式后，又回到插入模式
Ctrl+[ OR Ese - 退出insert mode
</pre>
