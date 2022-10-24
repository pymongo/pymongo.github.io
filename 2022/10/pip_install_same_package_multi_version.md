# [pip 包多版本管理](/2022/10/pip_install_same_package_multi_version.md)

pip 管理包用的是 system-wide 的方式，包下载到 /usr/lib 或者 $HOME/.local 内

一个包可以装多个版本，但多版本管理有的像栈一样 FIFO

例如 ipython 已装 1.0 版本此时再装 2.0 版本，则 import 的时候会用 2.0 版本

但实际上硬盘上两个版本都存了，只是该包全局的指针指向了 2.0

如果卸载掉 2.0 则 import 则会用上一次安装的 1.0 版本，所以说像一个栈

---

如果想卸载掉上一个版本再安装一个别的版本，可以给 pip install 加一个 --upgrade 参数
