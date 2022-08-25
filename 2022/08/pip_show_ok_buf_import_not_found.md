# [pip 存在但无法导入的包](/2022/08/pip_show_ok_buf_import_not_found.md)

在某个系统环境中我发现 pip show numpy 正常但 import numpy 报错 not found 或者 numpy.ndarray 找不到

原因是 python 包管理每个包的元信息和源代码分散在两个文件夹(这 python system-wide 包管理也太烂了)

通过 pip show numpy 返回的 location 字段得知 numpy 安装位置 `/lib/python3.9/site-packages`

进去后发现 numpy 就剩一个 **numpy.dist-info** 的文件夹 numpy 源码不见了

而 pip list 只看 **dist-info** 所以认为 numpy 存在

还有另一种情况是 numpy 源码存在但是不完整缺少个别 py 文件导致 numpy.ndarray 找不到

出事原因: 安装/升级某个依赖 numpy 的包，升级过程中卸载了 numpy 然后机器挂了没触发 pip 的事务回滚?
