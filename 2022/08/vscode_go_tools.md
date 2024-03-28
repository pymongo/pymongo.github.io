# [go tools](/2022/08/vscode_go_tools.md)

今天写 go 代码时 vscode go 插件警告我有两个核心的工具 dlv(用于 debug/test) 和 staticcheck (用于 lint) 我没装

<https://github.com/golang/vscode-go/wiki/tools#goplay>

archlinux 有个 go-tools 的包有另一些官方工具，本文介绍的工具则是 vscode Go 插件建议安装的工具 用 vscode Go Locale go tools 列出清单

```
go:	/usr/bin/go: go version go1.19 linux/amd64

gotests:	not installed
gomodifytags:	not installed
impl:	not installed
goplay:	not installed
dlv:	/home/w/go/bin/dlv	(version: v1.9.0 built with go: go1.19)
staticcheck:	/home/w/go/bin/staticcheck	(version: v0.3.3 built with go: go1.19)
gopls:	/home/w/go/bin/gopls	(version: v0.9.4 built with go: go1.19)
```

然后我点通过 vscode 安装，结果 vscode 不知为何 GOPROXY 没有设置上导致被墙装不上，还是我手动装

```
go install golang.org/x/tools/gopls@latest

#go install pkg.go.dev/honnef.co/go/tools/staticcheck@latest
go install honnef.co/go/tools/cmd/staticcheck@latest
go install github.com/go-delve/delve/cmd/dlv@latest

go install github.com/haya14busa/goplay/cmd/goplay@latest
go install github.com/josharian/impl@latest
go install github.com/fatih/gomodifytags@latest
go install github.com/cweill/gotests/gotests@latest
```

上述几个常用工具我点评下:

- staticcheck: 检查比 go vet 细致，go vet 发现不了的 unused var 它能发现
- gomodifytags: 一键给结构体的每个字段添加 json tag

还有就是开源社区常用的源码 license header 检查工具

> go install github.com/apache/skywalking-eyes/cmd/license-eye@latest

---

```
学习了 gomodifytags 可以给结构体自动加上 json tag
这就是我想要的 serde(rename_all="camelCase") 效果
之前我懒得一个个字段加 json tag
golang 反序列我习惯 map/interface 乱糊(interface 嵌套多了真的巨慢)例如

json["data"].(map[string]interface{})["records"].([]interface{})[0].(map[str
```

> https://twitter.com/ospopen/status/1561973110844592128

## Ctrl+S 自动删除未使用的 imports

```json
"[go]": {
    "editor.formatOnSave": false,
    "editor.codeActionsOnSave": {"source.organizeImports": "explicit"},
},
```
