# [gio mime](2021/11/gio_mime_type.md)

某日发现 dot 生成的 png 图 mime 类型不对

于是用 **file --mime** 命令参数去看

```
[w@ww target]$ file --mime a.png 
a.png: text/plain; charset=us-ascii
```

然而正常的 png 的 mime 应该是 image/png; charset=binary

## g_content_type_guess

<https://stackoverflow.com/questions/21532227/get-mime-type-from-file-extension>

以上链接介绍了一个通过文件扩展名让系统猜测 mime 类型的例子

例如输入 index.html 字符串输出 text/html

例子中用的是 gnome/gtk 的 gio API，即便我电脑是 KDE 的 DE 但大量应用也是 gtk 应用自然装了 gio

编译 stackoverflow 的代码例子要让 pkg-config 去找 gio-2.0 (用 whereis 是找不到的... )

> cc `pkg-config --cflags --libs gio-2.0` a.c

忽然想起 Rust 的 gtk 也要 gio 和 glib 依赖，所以 gio 还是值得一看的

## 不错的 kotlin gio binding 文档

<https://valadoc.org/gio-2.0/GLib.FileInfo.get_content_type.html>

kotlin gio 文档中居然有人工手写的 Example

当然我们 Rust 社区的 gtk-rs-core 的文档也不错，可惜没 kotlin 版文档中那么多例子
