# [colab](/2022/06/colab.md)

jupyterlab 跟 jupyter notebook 的区别应该是前者是一个 Jupyter 功能超集的 IDE

其实就比 jupyter 多了左侧文件树+可以编辑/可视化 csv 等文件等功能

这样的 IDE 然后还有很多对数据科学家/AI 开发的点，例如可视化 geojson

这么说 vscode/pycharms 也是一个 jupyter IDE

---

colab, deepnote 这类产品就像是多人协作版本的 jupyter web IDE

colab 免费用户还能使用 GPU(限时)，colab 可以无缝对接/mount Google drive 和 github 真的爽

colab 还能从 code snippets 中抄袭/学习很多高质量的 ipynb 模板

我个人对 colab 的体验感觉非常好，UI 和交互风格都跟 google docs 一致，学习成本低

## colab 容器内进程

```
  1  0.6  0.0    992     4Ss  /sbin/docker-init -- /datalab/run.sh
  8  0.9  0.3 339812 49680Sl  /tools/node/bin/node /datalab/web/app.js
 18  0.7  0.0  35888  4664Ss  tail -n +0 -F /root/.config/Google/DriveFS/Logs/dpb.txt /root/.config/Google/DriveFS/Logs/drive_fs.txt
 30  7.8  0.0      0     0Z   [python3] <defunct>
 31  0.6  0.3 155880 40836S   python3 /usr/local/bin/colab-fileshim.py
 44  2.0  0.4 199296 59948Sl  /usr/bin/python3 /usr/local/bin/jupyter-notebook --ip=172.28.0.2 --port=9000 --FileContentsManager.root_dir=/ --MappingKernelManager.root_dir=/content
 45  0.0  0.0 715352  5472Sl  /usr/local/bin/dap_multiplexer --domain_socket_path=/tmp/debugger_127d5885ir
 62  4.2  0.6 473372 92832Ssl /usr/bin/python3 -m ipykernel_launcher -f /root/.local/share/jupyter/runtime/kernel-44e369ee-d279-475e-9471-ec016dc4c972.json
 82  0.0  0.1 126928 15052Sl  /usr/bin/python3 /usr/local/lib/python3.7/dist-packages/debugpy/adapter --for-server 41303 --host 127.0.0.1 --port 20859 --server-access-token cb370bbd7d190afea4adc6c268de9e1a07c9119ccb7989ab1a70acfa54ca866f
 99 23.7  1.2 571272 166404   node /datalab/web/pyright/pyright-langserver.js --stdio --cancellationReceive=file:09698005fead9c7514f8bd97566b882c6f86424f15
```

## colab 的杀手锏功能

运行代码时底部状态栏会「实时打印 Python 调用栈」应该是通过 debugpy 实现的

无缝对接谷歌网盘也算亮点，但并非必须功能，无缝对接 github 的话 github1s 和 github.dev 都有从 repo 到 vscode 的功能
