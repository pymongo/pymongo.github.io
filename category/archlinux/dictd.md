# [archlinux 字典](/category/archlinux/dictd.md)

受不了 dict.cn 网页查询太慢不方便，而且不支持离线查询，我调研了一些在线和离线查询的词典解决方案

## 有道

§ yay -S youdao-dict

最容易安装就是 youdao-dict(aur) 还支持离线查询

§ yay -S wudao-dict-git

`wd` 是一个联网查询有道 API 的命令行字典工具

## golden dict

用[mdict 平台](https://mdict.org/categories/english-chinese/)
牛津词典

在 golden dict 的 dictionary 中添加牛津词典的目录，然后点 rescan 就能用牛津英汉词典了

## dictd(可行性不行)

yay 那些 dict-* 开头的 dict 词典包暂时没有一个是中文的词典数据

根据 archlinux dictd wiki 的介绍，dictd 出现 Parse Error 是因为没有词典

需要在 /etc/dict/dictd.conf 的末尾加上以下词典的配置

```
#
#LASTLINE

database oxford {
  data /home/w/files/apps/oxford_english_chinese.mdd
  index /home/w/files/apps/oxford_english_chinese.mdx
}
```

然而我按照 wiki 上的步骤做好后 dictd 依然没法正常启动，可行性太差

可能是 mdict 平台上下载的 .mdd 数据格式 dictd 并不支持

- dict: 虽然不能连 dictd 查询，但是还能在线查询 eng-eng 词典
- gnome-dict: 需要 dictd 正常工作后才能执行

---

Reference:

- <http://blog.lujun9972.win/blog/2019/03/01/dictd-%E6%9E%84%E5%BB%BA%E8%87%AA%E5%B7%B1%E7%9A%84%E5%AD%97%E5%85%B8%E6%9C%8D%E5%8A%A1%E5%99%A8/index.html>
- <https://wzyboy.im/post/1237.html>
- <https://www.jianshu.com/p/661c8e5bed86>
