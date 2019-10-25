# vim register and select/copy

vim的文本选取没什么好讲的，v进入vision模式，V进入vision line模式，之后就是看你光标移动的熟练程度了

## via vaw选中当前的单词

i其实就是inner的意思，viw用到了vim的TextObject

## vit选中html标签内容

!> 同理diw cit能实现删除单词的功能

## vi" 选中双引号内内容

## clipboard and anonymous register

> [!NOTE|label:MacOnly]
> :set clipboard=unnamed

这句话的意思是匿名寄存器和粘贴板公用存储空间



!> vim的DD是剪切的说法并不对，vim被删内容实际是放进匿名寄存器里

需求：想粘贴板存多个值、想查找替换时不用输入一大串

vim有很多个寄存器从a-z还有0-9等,为了可读性和易用性a-z这几个都够你用了

调用寄存器的方法： 双引号+寄存器名

如： 5”ap 就是把a寄存器的值粘贴五次

:regs 显示所有寄存器的值



## vim Undo/Redo/Repeat

u/Ctrl+r/. Undo/Redo/Repeat 

U撤销行内命令