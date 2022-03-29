# [wine 企业微信中文乱码](/2022/03/wine_wxwork_chinese_display.md)

改开始菜单的企业微信的 desktop 文件没啥用，似乎不会保存，
要去 ~/.local/share/applications/wine 里面改 desktop 文件加上 LANG=zh_CN.UTF-8

同事的 kubuntu 21 装 wine 企业微信启动时闪退报错 dll 缺失，我看了半天也没解决

---

说到 wine 我想起了我最近解决的玩一些游戏会 gfxerror 的报错，解决办法是在 fedora 上要用 wayland 去玩游戏
建议安装上 lutris 让它自动给系统安装上很多游戏必须的 wine 库
