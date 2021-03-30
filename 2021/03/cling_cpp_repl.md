# [cling C++ repl](/2021/03/cling_cpp_repl.md)

苦于C/C++想要运行几行代码还得创建新文件，配置cmake/gcc编译等繁琐步骤，拖慢了我学习C++的速度(像我比较熟悉的js,py,rb,rs都有repl环境)

一个文件只能有一个可执行函数的入口，导致我想验证一段代码的正确性需要更多的时间去处理编译写cmake等步骤让代码能运行起来

不能像Rust那样一个源文件内可以有多个可执行函数，于是我搜搜C++有没有REPL的工具

现有的解决方案是jupyter+cling_kernel，当然cling本身也是个C++的repl工具

(当然vscode上官方cmake插件也是相当好用，vscode开发体验上 rust>cmake>golang>jupyter>>python )

## jupyter的权限问题

虽然pacman有jupyter的包，但是python的可执行工具就该用pip去装，这样能装到用户文件夹内减少权限问题

`sudo pip`会将包装在`/usr/lib/python3.9/site-packages/`

推荐别加sudo，pip会将包装在`~/.local/lib/python3.9/site-packages/`

此时需要jupyter默认的python3 kernel的位置，如果不在用户文件夹内则会报错

> [Errno 13] Permission denied:/usr/local/share/jupyter

以上是ubuntu的报错，arch的报错则是/usr/share/jupyter没权限

如果jupyter打开ipynb出现以上错误时，则必须要改掉kernel配置，否则就只能sudo运行jupyter，例如vscode没有root权限，就无法使用jupyter了

⭐将jupyter的python kernel改回usr权限:

> python -m ipykernel install --user

⭐列出jupyter kernel的安装位置:

```
[w@w-manjaro temp]$ jupyter-kernelspec  list
Available kernels:
  python3    /home/w/.local/share/jupyter/kernels/python3
```

## cling or root?

由于cling只有aur包不能用pacman安装，而且aur上的cling无论源码编译还是二进制分发全都安装报错

而且手动下载ubuntu版本的cling二进制也容易出错，还是用pacman上的root包代替cling(root和cling出于同一个团队)

cling另一个缺点是，jupyter想用cling需要安装clingkernel，而clingkernel这个python包没托管到包管理中

clingkernel只能本地安装，不如jupyter root kernel依赖的metakernel方便

其实root是一个类似anaconda/jupyter那样的C++科学计算工具链，cling只是root其中一个工具

## install root C++ kernel

> pip install jupyter metakernel

arch linux 安装root-project/root

> sudo pacman -S root

jupyter-kernelspec添加root kernel

> cd /etc/root/notebook/kernels/

## C++ kernel使用体验

由于cling/root的命令行repl工具不方便编译多行输入的代码，也不能记录历史的输入输出，所以jupyter工具还是很方便的，听说甚至支持opencv或C++读写打印图片

其实CLion的codeLen也算方便了，新建cpp文件+cmake配置加一行executable配置+reload，Clion就会识别新的可执行文件的main函数，并在左边加上类似vscode的codeLen可以运行之 ~~可惜CLion破解版在linux下UI经常崩溃卡屏~~

因为vscode的jupyter渲染是内嵌网页的缘故，所以emacs插件也不生效了，而且不支持C++代码高亮，那我干脆用网页版的jupyter客户端算了

首先cling/root会自动导入iostream,vector,algorithm等包，并且会自动using namespace std

cling/root另一个比较爽的事情是会自动加载操作系统上的所有动态链接库，例如sqlite3.h不需要include也能调里面的方法

---

jupyter插件管理器安装(待确认)

```
pip install jupyter_contrib_nbextensions
jupyter contrib nbextension install — user
pip install jupyter_nbextensions_configurator
jupyter nbextensions_configurator enable
```
