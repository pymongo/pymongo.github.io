# eclipse安装与配置

## 下载eclipse

eclipse类似VisualStudio能给多种语言编程的IDE

因此eclipse有两种安装方法：

- 安装eclipse下载器后再安装JavaEE
- 解压JavaEE压缩包即可用【推荐】(protable)

<img src="/img/eclipse-config/01-eclipse-download.png">

记得点下面的download package

<img src="/img/eclipse-config/02-eclipse-packages.png">

选择下载量最大的也就是JavaEE包

## 文件编码改为UTF-8

第一次打开eclipse，就用默认的workspace路径好了

看到【欢迎界面】后，右下角勾上 don't show again，叉掉欢迎界面后看到正常界面了

<img src="/img/eclipse-config/03-disable-welcome.png">

eclipse可能跟微软有合作，居然默认用微软的【编码】方法

<img src="/img/eclipse-config/04-change-encode.png">

都2018年了eclipse的【自动保存】居然要延迟1s，默认没启用自动保存

<img src="/img/eclipse-config/05-autosave.png">

## 自动补全

eclipse默认补全嗅探太烂了，而且还是按Enter键进行补全

文件编码和自动补全真是违反行业规范，也是逐渐没人用eclipse的原因之一

`window->preference->搜索advance`

<img src="/img/eclipse-config/06-auto-complete.png">

将 `Auto activation triggers for Java`

改为 `.abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ`

虽然现在有下拉菜单式的补全提示，可是要按enter才能补全

eclipse改建不支持多对一，没法吧Alt+/改为Tab

只好用sharpKey把大写锁定键改成Enter，毕竟大写键基本不用却占用这么好的位置，

而且大写键和tab很近，也便于肌肉记忆

<img src="/img/eclipse-config/07-sharpkeys-caps-to-enter.png">

## Java路径设置

`preference->Java->Installed JREs`

<img src="/img/eclipse-config/08-eclipse-java-path.png">

## 高对比度下的theme

开启高对比度后eclipse会切换成黑白主题，需要手动强制设回默认主题

不然失去了代码高亮

<img src="/img/eclipse-config/09-eclipse-high-contrast.png">

## 其它设置

- 字体大小
- 重置窗口布局-window->perspective->reset