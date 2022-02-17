# [安装 fcitx5 小鹤双拼](/category/archlinux/fcitx5_xiaohe_shuangpin.md)

由于rime的配置过于麻烦，后来我发现fcitx5已经自带小鹤双拼，而且还能内嵌到KDE的设置菜单内，那就用fcitx吧

## fcitx5安装

- archlinux: pacman -S fcitx5-im fcitx5-chinese-addons
- fedora: dnf install fcitx5 fcitx5-autostart fcitx5-chinese-addons fcitx5-configtool fcitx5-gtk fcitx5-qt

`fcitx5-im`已经包含`fcitx5-gtk`和`fcitx5-qt`

然后在`~/.xprofile`中加上三行后重启即可生效(加到`~/.xinitrc`里是没用的)

```
# 据说fcitx5改成fcitx也行
export GTK_IM_MODULE=fcitx5
export QT_IM_MODULE=fcitx5
export XMODIFIERS=@im=fcitx5
```

关于fcitx5的配置，云拼音肯定要的(否则连知乎这个词都不认得)，输入预测就很傻，每打一个词就联想下一个要输入的是逗号...

使用idea/jetbrains全家桶时(或非GTK非QT应用)，输入法候选框永远在左下角。fcitx5在arch linux wiki上也有提到这个Bug，可能是java应用都有的问题

## fcitx5黑暗主题

fcitx5黑暗主题，由于arch的包`fcitx5-material-color`全是白色主题，我推荐用`fcitx5-themes`这个主题

```bash
cd ~/temp
git clone https://github.com/thep0y/fcitx5-themes.git
cd fcitx5-themes/
cp -r winter ~/.local/share/fcitx5/themes
```

将theme文件拷贝过去后，在fcitx5->addons->classic_user_interface中就可以选用该主题了

## 禁用Ctrl+.切换半角全角的快捷键

因与vscode的quick_fix快捷键是Ctrl+.冲突(类似idea的Alt+Enter code_action)，需要禁用掉半角全角切换的快捷键

具体的设置项在 fcitx5的Punctuation addons里

## Ctrl+Alt+P切换单双行显示

可以在 fcitx->global_options中关闭该快捷键

## fcitx5内置输入法的一些技巧

- 默认下"]"键可以输入直角括号「」
- 为了照顾emcas`C-space`进入选中文本模式，我把输入法切换的快捷键改成alt+shift

## 参考文章:

- <https://blog.ruo-chen.wang/2020/05/install-fcitx5.html>
- <https://a-wing.top/linux/2018/08/14/fcitx5.html>
- <https://ywnz.com/linuxmh/8100.html>
