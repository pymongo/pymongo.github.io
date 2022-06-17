# [ipy magic cmd](/2022/06/ipython_magic_command.md)

jupyter/ipython 的 magic command 功能很多，可以 %%javascript 执行一个 js 代码 cell

也可以 %time 测量，不过我更关心的是 how magic command work

---

从行为上看 magic command 就像是一个宏做一些 meta programming 的事情

当然也没有操作 AST 那样强大，其实看上去 magic command 最终会替换成 python 代码而已

## pre_execute

根据 ipython 开发者文档 docs/source/development/execution.rst 将代码执行(handle execute_request)过程分成几个过程

- pre_execute(做 magic/shell command 展开替换成 py 代码)
- pre_run_cell(此时还没到 ipykernel)
- run_cell(这时候代码通过 shell zmq socket 从 jupyter 发给 ipykernel)
- post_execute

所以会发现代码展开的过程中会将 %foo 替换成一段 python 代码

我试试故意输入缩进错误的 magic command 代码，通过报错的代码就能看到 %ls 会替换成什么

```
a=1
 %ls
```

果然出现了缩进报错

```
    get_ipython().run_line_magic('ls', '')
    ^
IndentationError: unexpected indent
```

## IPython.get_ipython()

get_ipython() 的返回值:

|||
|---|---|
|py 文件| None |
|ipython| IPython.terminal.interactiveshell.TerminalInteractiveShell |
|jupyter notebook| ipykernel.zmqshell.ZMQInteractiveShell |
|google colab| google.colab._shell.Shell |

两个百分号 %% 会替换成 get_ipython().run_cell_magic()

一个百分号 % 会替换成 get_ipython().run_line_magic()

!pwd 会替换成 .system 如果带管道则替换成另一个函数

经过替换后 %magic 的返回值就能赋值给变量了

## inputtransformer2

继续读 ipython 文档发现 IPython 的 inputtransformer2 库

```
>>> c = '''
... a = 1
...   !pwd
... %pwd
... c = 3
... # 123'''
>>> cls = IPython.core.inputtransformer2.TransformerManager()
>>> c = '''
... a=1
...  !pwd
... %pwd
... #1
... d=2'''
>>> c
'\na=1\n !pwd\n%pwd\n#1\nd=2'
>>> cls.transform_cell(c)
"a=1\n get_ipython().system('pwd')\nget_ipython().run_line_magic('pwd', '')\n#1\nd=2\n"
```
