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

## Ctrl+v同时编辑多行

需求：给连续多行前面加上注释

Ctrl+v 进入visionBlock模式 选中连续五行的首字母然后I插入

插入的时候不会显示编辑了多行，退出插入模式时才会出效果

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

J 可以把下一行“吸管”上来

## 怎样打HTML标签

我倾向于使用寄存器存一个div