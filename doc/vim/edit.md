# vim eidt,tab,spilt(分屏)

## new tab

!> vim -p file1 file2 以多标签的方式打开多个文件

:tabe fileName

:tabfind pathName # 查找一个文件并在新的标签页打开，如果有多个匹配结果会报错

:tabnew


## 标签切换

gt/gT - switch tab

2gt - 切换到标签2

:tabm N - 把当前标签页移动到第N，N不指定的话移动到最后

:tabs - 显示所有标签页的信息

## 分屏

屏幕间跳动有两种方法

1. Ctrl+,hjkl - move cursor between window
2. Ctrl+w,w

!> 或者Ctrl+i/o 在最近两个编辑的文件间跳动

vim -o/O file1 file2 # 水平/垂直分屏打开文件

Ctrl+W,= - 让所有屏宽度一样

<pre>
「,t」OR「:NERDTree」 - sidebar file explorer
,q - close window(custom setting)
Ctrl+E OR :MRU - recent files
:vs/sp file - 左右、上下分屏
:e file - open file
</pre>

## 删除

c和d二者的功能完全一样，区别是c在d完后直接进入插入模式 

常用大C删除当前光标到行尾

常用删除的命令有 x s d c

## 怎样打HTML标签

我倾向于使用寄存器存一个div