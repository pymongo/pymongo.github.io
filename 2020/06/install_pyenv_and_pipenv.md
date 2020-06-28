# [mac/Ubuntu上安装pyenv和pipenv](/2020/06/install_pyenv_and_pipenv.md)

Python官方没有提供像nodejs的npm或java的maven/gradle这样的第三方包管理工具+项目构建工具

## mac安装pyenv

安装的话用homebrew安装，然后在~/.bash_profile文件中加两行

export PATH="$HOME/.pyenv/bin:$PATH"

eval "$(pyenv init -)"

```
# 初始化rbenv
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# 初始化pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
```

pyenv通过访问python.org下载python，而国内的网络连python.org很慢，这里建议开代理或用镜像源

我的mac系统是10.14，用pyenv安装其它python版本时报错了

> ImportError: No module named pyexpat

阅读[Issue](https://github.com/pyenv/pyenv/issues/544)
后发现，需要指定CommandLineTools的路径才能安装

> SDKROOT=/Library/Developer/CommandLineTools/SDKs/MacOSX10.14.sdk MACOSX_DEPLOYMENT_TARGET=10.14 pyenv install 3.8.3

如果安装了Xcode，可能要指定Xcode的CommandLineTools路径才行

## mac安装pipenv

由于pyenv接管了python版本，我是不建议用pip安装pipenv，用homebrew能保证切换python版本后也能找到pipenv的路径

## Ubuntu安装pyenv

可惜的无法通过 apt install pyenv pipenv 去安装 

curl https://pyenv.run | bash

跟mac一样，要在~/.bashrc里加两行

## Ubuntu安装pipenv

sudo pip3 install pipenv

一定要sudo才能保证全局安装、全局获取到pipenv二进制文件的路径
