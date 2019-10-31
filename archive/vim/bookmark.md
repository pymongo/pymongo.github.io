# [bookmark & macro & collapse](archive/vim/bookmark)

## bookmark简单用法

ma 设定书签a  
`a 跳到书签a  
'a 跳到书签a的所在行  
:delmarks a  删除书签a

## marco 

1. qd	start recording to register d
2. ...	your complex series of commands
3. q	stop recording
4. @d	execute your macro
5. @@	execute previous macro

## marks标记简单用法

ma 设定标记a  
`a 跳到标记a  
'a 跳到标记a的所在行  
:delmarks a  删除标记a

## 折叠代码zf/zd

常用 zfap 折叠一个代码段,再用zd展开代码

## 删除

c和d二者的功能完全一样，区别是c在d完后直接进入插入模式 

常用大C删除当前光标到行尾

常用删除的命令有 x s d c

J 可以把下一行“吸管”上来

## 部分mode切换快捷键

<pre>
x/X - Delete/Backspace
s - 右删除一个字进入insert mode
S - 删除行并插入
R - replace mode
Ctrl+O - 使下一个按键临时进入普通模式后，又回到插入模式
Ctrl+[ OR Ese - 退出insert mode
</pre>

## vim通用
「:! 」 - 临时执行shell命令,如:! touch p.py
Ctrl+z - 暂时挂起vim (推荐用小指指腹按Ctrl)
fg - 回到vim
:wq、:x、ZZ - save and exit
Ctrl+g - show file and current line info

## 格式化代码

== - auto format current line

\>> and << 实现单行缩进调整

