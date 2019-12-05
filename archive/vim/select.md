# [select & register](archive/vim/select)

常用set nonu/nonumber 隐藏行号以便复制代码

Ctrl+v是visiual block模式估计就只有以下一个用处(在大师的配置离里Ctrl+v是打开View文件)

## Ctrl+v唯一应用: 多行加注释

需求：给连续多行前面加上注释

Ctrl+v 进入visiualBlock模式 选中多行的首字母然后I插入

插入的时候不会显示同时编辑了多行，退出插入模式时才会出效果

更好的解决方案,用插件,选中代码后,cb 或者给一行加上注释后用.给其他行重复操作

## vi"选中当前的双引号内的内容

vaw选中当前双引号及其内容

vit选中html标签内容

!> 同理ciw能实现删除单词的功能

学会这招后就可以不需要visualMode也能选中代码

## clipboard and anonymous register

!> vim的DD是剪切的说法并不对，vim被删内容实际是放进匿名寄存器里

需求：想粘贴板存多个值、想查找替换时不用输入一大串

vim有很多个寄存器从a-z还有0-9等,为了可读性和易用性a-z这几个都够你用了

调用寄存器的方法： 双引号+寄存器名

如： 5”ap 就是把a寄存器的值粘贴五次

:regs 显示所有寄存器的值

## 检查vim是否支持剪切板

> /usr/bin/vim --version | grep clipboard

如果结果出现 "-clipboard"说明不支持剪切板

vscode或idea的vim都是支持剪切板的

用 "*p 或 "+p 粘贴剪切板内容


