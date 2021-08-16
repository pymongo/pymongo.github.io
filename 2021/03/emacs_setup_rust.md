# [尝试用emacs配rust lsp](/2021/03/emacs_setup_rust.md)

首先要从melpa源获取package list(类似apt update)

```
$ kate ~/.emacs.d/init.el
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(package-refresh-contents)
```

然后打开emacs安装rust-mode

M-x package-install(Enter) rust-mode(Enter)

然后继续安装lsp-mode package

then add `(require 'rust-mode)` `(require 'lsp-mode)` to init.el

装完rust-mode插件后就可以把init.el配置文件中package那4行注释掉，不然每次启动都要联网更新包的索引，启动emacs都要等好几秒

然而出现两个报错:

> cause of the error in your initialization file

> \[LSP] Unable to autoconfigure company-mode

还是vscode+ra或Intellij-Rust够简单傻瓜无需配置好用，vscode就多写一个rust-analyzer.server.path的json配置项就好了

实在难以理解用lisp写lsp-mode的一堆配置，用json不香么
