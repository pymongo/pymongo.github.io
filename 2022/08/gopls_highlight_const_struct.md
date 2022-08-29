# [gopls 高亮常量](/2022/08/gopls_highlight_const_struct.md)

看 kubernetes 源码的 pkg/api/pod/util.go 发现 vscode 没给常量高亮，变量跟常量全是白色的没法区分

加上下述设置后，vscode 打开 go 文件会变慢但能高亮更多符号了

> "gopls": { "ui.semanticTokens": true }

reference: <https://v2ex.com/t/875494#reply5>
