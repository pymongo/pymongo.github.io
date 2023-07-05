# [emacs初体验](/2020/08/emacs_first_attempt.md)

尝试了emacs以后，让我IDEA系列软件的快捷键布局都改成了emacs再加上ideaVim

以前移动到文件头部只能用win+Home(不开vim Emulator的情况下)，现在可以用C-<

Ubuntu安装无图形界面版本的emacs: `apt install emacs-nox`

emacs快捷键表示中`M-v`表示按住Meta/Alt键后按v，同理`s-`开头表示按住win/command键(这个要记下)，

`S-`开头表示按住shift的快捷键，但是 shift 一般就只用于打大写字母或符号，emacs官方几乎没有需要按Shift的快捷键(我推测的)

首先要学的是退出emacs: `C-x, C-c`

让我想起"如何退出vim"都能成为Stack Overflow的热门问题，不就:q或ZZ两种方法，不难记

那么emacs有没有类似vimtutor一样的官方教程呢?

有的，通过 `C-h, t` 进入emacs官方教程

<i class="fa fa-hashtag"></i>
光标移动

根据教程提示，光标上下左右移动跟mac系统的C-p/n/f/b一样，

M-f/b: 类似vim的w/b，一个个单词地移动光标，mac的Terminal里也是可以用M-f/b去按单词为单位去移动

C-a/e: 行首/行尾，Mac系统也自带这一对快捷键

M-a/e: 句首/句尾，这个需要记忆下

M-\</>: 文件首/文件尾，总比win+Home

中止操作: C-g, C-u重复8次操作(类似vim): `C-u, 8, C-f`

M-!: 执行shell命令

C-u 286 M-g M-g will jump to line number 286

以下是我整理出来的官方教程的笔记:

- C-v/M-v: PgUp/PgDn
- C-l: 屏幕居中到光标所在行
- C-y: paste
- C-x,u|C-/|C-_: undo
- M--|C-g,C-/: redo(Alt+-)
- C-d: 向右删除一个字符
- M-Del/d: 向左/向右剪切一个单词
- M-k: 剪切光标到句尾
- C-k: 剪切光标到行尾
- C-w: 剪切光标到行首内容
- C-y, M-y: 翻找以前的粘贴板，将粘贴内容替换为更早的粘贴板内容

可以练习下C-y C-/ M--三连，paste undo redo，熟悉下手感

## 窗口操作

- C-x,b: 打开buffer列表, C-x,1关闭底部窗口
- C-x,1: 除了窗口1，关闭其它窗口
 
## IDEA emacs布局缺失的组合键

用了emacs之后好多快捷键都没了，我还是先用macOS默认的快捷键加上一些emacs的快捷键就够了

- M-a/e: 将光标移动到句首/句尾

---

初次体验完emacs教程后，感觉先阶段学习emacs的收益不高

再看看我leetcode才刷了225题，排名22500+，还是继续快乐刷leetcode去了

最近几个月的下班时间都在刷牛客网面经/背面试题+刷leetcode，所以博客就没时间更新了
