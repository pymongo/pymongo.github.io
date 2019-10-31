# 多人协作下的git问题

一个人用git版本管理，只需要会add commit push pull这四个命令就够了

## 多人协作下更多的git命令

— git log
- git reset 撤回本地的commit
- git checkout —— fileName 回滚某个文件到某历史版本

## git fetch和git pull

git fetch origin master这句话origin的意思是代码仓库别名

比如同一个repo在coding.net和github上都有仓库,以github为主的话

github的仓库别名就用默认的origin，码云的代码仓库名字用backup

## git show偷懒技巧

只要没有重复 git show commitID的前几位就可以查看该次commit的详细信息

## 不要用rebase

使用rebase会改变时间线，破坏了版本的时间信息等。

没必要为了减少merge branch而进行rebase，风险远大于收益