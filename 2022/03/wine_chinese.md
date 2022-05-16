# [wine 中文乱码](/2022/03/wine_chinese.md)

windows 系统自身就装了宋体中文显示没问题的，其实就是 Linux 系统 LANG=en_US.UTF-8 的原因

```
cd /home/w/.wine/drive_c/Program Files (x86)/WXWork
LANG=zh_CN.UTF-8 wine WXWork.exe 或者 LANG=zh_CN.UTF-8 ./WXWork.exe
```

上述启动方式相应的终端关掉后微信就没了

如果想启动在后台 systemd-run --user 启动要用相应的 set-env 参数不能用 export

最方便的做法还是修改 ~/.local/share/applications/wine/Programs/企业微信/企业微信.desktop

加上 LANG 就好

