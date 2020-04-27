# [chrome导出插件](/2020/04/chrome_export_extension.md)

随着我英语水平的提高，英语的技术文章每段话大约就4~7个单词看不懂

所以需要一个双击单词即刻翻译的软件，我发现我同事的`Google 划词翻译`插件还不错

于是去Google应用商店去搜索，发现已经下架了...

只好从同事电脑中导出插件再发给我安装

---

1. 开启chrome extensions的开发者模式

在chrome://extensions/的右上角有个toggle按钮开启开发者模式

2. 找到插件的文件夹导出插件

先记着需要导出插件的ID，开了开发者模式后插件主页左上角有"导出插件"的按钮

通过以下路径找到插件所在文件夹，文件夹的名字就是ID，然后密钥一栏可以不填

> ~/Library/Application\ Support/Google/Chrome/Default

导出生成的crx文件会放在插件的目录里

3. 将导出的crx转换为zip

我在[crxextractor.com](http://crxextractor.com/)网站将crx文件转为zip

通过zip压缩包就可以在另一台电脑上导入插件了

[我把这个文件上传到图床分享给大家了](https://showmethemoney.hnengdata.com/apk/Google划词翻译插件.zip)
