# [arch pip TypeError](/2022/06/arch_pip_fail_after_system_upgrade.md)

在一次 arch 升级了 python 小版本之后我的 pip 坏了

安装已有包百分百报错:

> TypeError: expected string or bytes-like object

安装新包会逐个下载该包每个版本然后尝试安装时都报错 `ERROR: No matching distribution found for`

<https://github.com/pypa/pip/issues/9348>

原来看 issue 说卸载掉用户文件夹内的 setuptools 即可，转而用系统的 python-setuptools 就没事

> pip uninstall setuptools

python 这系统包管理和 pip 包管理都能全局装包真是天坑
