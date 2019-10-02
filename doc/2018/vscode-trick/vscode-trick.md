# vscode技巧・正则表达式置换等

[egghead.io](http://egghead.io)上面现在有VScode的教程，等我看完后再更新本文吧...

## regax replace

I want `<img src=/img/example>` to `<img src="/img/example"`

warp src attr with double quote

相关问题： [stackoverflow](https://stackoverflow.com/questions/43577528/visual-studio-code-search-and-replace-with-regular-expressions)

`<h3>(.+?)<\/h3>` match content <mark>inside</mark> h3 (innerHTML)

![01-regax-replace](01-regax-replace.gif "01-regax-replace")

Source: `<img src=/img/vscode>`

Regax:&nbsp;&nbsp;`<img src=(\/.+?)>`

Replace:`$1 = /img/vscode`

Result:&nbsp;&nbsp;`<img src="$1">`

## F2重命名变量

这个快捷键我是从官方的refactor(代码重构)文档看到的

![02-rename-var](02-rename-var.gif "02-rename-var")