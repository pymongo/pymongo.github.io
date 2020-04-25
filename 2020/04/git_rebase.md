# [复盘第一次rebase](/2020/04/git_rebase)

老大曾经教过我，不要用rebase，使用rebase会破坏以前commit的时间戳，会破坏历史记录等等。

所以我和同事们宁可多个分支Merge3-4重也不会rebase去减少分支嵌套。

最近我整理win10电脑上的文件，无意中发现我以前注册过一个aoxiangwu的github账号，也有github page，于是想登录github把这个域名做成我博客的镜像/额外的remote。

但是太久没登录了需要邮箱验证吗，可是关联的谷歌邮箱早就被封号的(没干过什么，太久没登陆谷歌以为我账号是机器人或spam就封号了)

问题是之前aoxiangwu的仓库是另一个网站项目，和我博客的仓库commit不一样

好在我还记得github的账号密码，只好clone下来准备rebase了！

注意`git pull --rebase`之后，你会发现当前仓库不处于任何一个branch中

rebase的话是根据aoxiangwu的仓库，从第一条commit开始逐条merge

相当于我以pymongo最新的仓库去逐条合并aoxiangwu已有的commit

这个过程真是「体力活」，index.html各种conflict，合并完一条后 git rebase --continue

git pull pymongo --rebase完了以后，还要git pull origin将原仓库的分支给merge过来

不过将两个仓库的提交记录合为一个时会报错`refusing to merge unrelated histories`

```
C:\Users\w\workspace\aoxiangwu.github.io>git pull origin master
From https://github.com/aoxiangwu/aoxiangwu.github.io
 * branch            master     -> FETCH_HEAD
fatal: refusing to merge unrelated histories

C:\Users\w\workspace\aoxiangwu.github.io>git pull origin master --allow-unrelated-histories
```

解决完报错以后，我的仓库终于能用了
