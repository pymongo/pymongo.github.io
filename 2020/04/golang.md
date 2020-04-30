# [Go语言研究](/2020/04/golang.md)

最近我在读一些go项目的源码，发现go一些关键词跟Rust语言一样，例如`panic`、`fmdt`，

Go自带了benchmark、test的功能，Rust也是自带了bench和test功能，

到底是什么原因导致国内使用Go的人数远超Rust？

知乎上的回答普遍是Go比Rust简单，耳听为虚眼见为实，我要亲自研究下Go与Rust的差异

我花了半小时看完Go语言的菜鸟教程，初步结论是Go的channel多线程通信确实比Rust简单多了

本文尽量抛开Rust与Go的比较这种低层次的研究，希望重点放在Rust和Go是如何解决软件开发现有的一些痛点

我很欣赏Go的goroutine+channel杀手锏，切实解决了软件开发并发/多线程的痛点，Rust的MPSC channel就复杂多了

我打算以哲学家进餐问题为例单独写篇文章研究下Go的goroutine+channel

---

## 方法论:如何学习新语言

对于掌握多门编程语言有经验的开发者而言，以下是我认为最佳的学习路线

1. 学习包管理/项目构建工具，例如maven/npm，理解项目文件结构
2. 利用第三方依赖开发一个http client/server，能读写简单的json数据
3. 简单了解下新语言的单元测试和benchmark的使用
4. 去leetcode上找Easy的题做一道
5. 解决哲学家进餐问题，理解新语言在多线程上的应用

## actix和gin性能比较

我测试了rust和go star数最多以及最快的框架，用ab -n 1000 -c 200在我本地的mbp2019(i5 8G内存)上的测试结果是

actix(17000)，rocket(6000)，gin(16500)，iris(21000)

没想到Rust star最多的rocket框架性能如此糟糕😰

由于gin打了log会影响性能，actix和iris都没打，所以gin和actix的性能实际上差距不大

而iris能领先gin/actix 15%~25%的性能，每秒甚至能处理23000个请求(10倍于rails)，实在强悍

所以知乎上有人说Rust比Go快这样的观点实在是太片面了

或者techempower.com的跑分测试actix远超go也是不显示

不过Rust开启编译器优化之后性能提升空间很大，Go开启优化后的提升相对小点

我用ab -n 5000 -c 5000通过返回"pong"字符串的接口测试了Rust和Go开启编译器优化后的性能。Rust-actix每秒能处理25368个请求，Go-iris能处理25787个请求。

Rust从Debug版编译换成release版编译加上一些编译优化后，性能从1.7万提升到2.5万，而Go只是从2.2万提升到2.5万

> Go语言最快的iris框架开启编译器优化后的速度

![](go_iris_benchmark.png)

> Rust语言开启release版本编译后的速度

![](rust_actix_benchmark.png)

Rust编译器选项里可以把默认的内存管理器换成FreeBSD的jemalloc或者微软的mimalloc，具体效果如何我没尝试了。

我mac电脑ab命令最多开到5000并发，开1万或2万并发会提示socket地址不够用了，可能我之前不小心用chown改了文件权限，也可能是端口本来就不够用。

我在Ubuntu测试服务器上ab命令能开到2万并发，所以测试结果仅供参考

## Go包管理工具

在官方没有推出go-modules包管理工具时，有一些第三方的包管理解决方案，如go-vendor

不过go-modules并不像maven/npm那样管理第三方工具的同时还能构建项目

> go mod init go_http_client

会生成一个go.mod的文件

在main.go中添加`import "github.com/gin-gonic/gin"`(Go知名Web服务器)后

执行`go mod tidy`会自动将依赖下载到`GOPATH/pkg/mod`中

此时go.mod文件多了一行`require github.com/gin-gonic/gin v1.6.2`

还多了一个go.sum文件(类似package.json-lock)

如果希望将项目依赖的包移到项目文件夹内，可以使用`go mod vendor`。

## Go项目构建

[golang-standards/project-layout](https://github.com/golang-standards/project-layout)

我非常喜欢Rust语言在一个项目里能定义多个bin，以及多个examples的特性，写完一个函数就能直接运行的爽快体验

[How to structure Go application to produce multiple binaries?](https://stackoverflow.com/questions/50904560/how-to-structure-go-application-to-produce-multiple-binaries/50904959)

[golang 的编译没有 debug release 之分吗？](https://www.v2ex.com/t/561636)

让我感到难受的是，go构建项目还得「背下」go build命令「参数的先后顺序」

> go build -o ${output} {source.go}

## Go可能不合理的设计

本文不希望是踩Go来吹捧别的语言，这样做很无聊也没有意义，我希望研究Go是如何解决计算机的各种问题的，

所以本章节只是挑几个我不喜欢Go的地方，不会过多抨击Go

<i class="fa fa-hashtag"></i>
驼峰式变量命名

I like snake case rather than camcelcase.

驼峰式命名变量的单词数少于3个还好，要是变量名是3个或以上的单词组成，用snake case可读性会好很多

而且我个人很不喜欢Go或Rust社区将单词缩写的风格，例如server缩写成srv、context缩写成ctx

看Rust Actix时各种ctx缩写让人有歧义，Actix有WebSocket的Context也有各种各样的Context，都写成ctx为了省几个字母，都没讲清楚指的是什么context

<!--
<i class="fa fa-hashtag"></i>
枚举类型可读性查

```go
const (
	gender_male = iota
	gender_femail = iota
)

const (
	trade_type_buy = iota
	trade_type_sell
)

func main() {
	gender := gender_femail
	trade_type := trade_type_sell
	fmt.Println(gender) // 1
	fmt.Println(trade_type) // 1
}
```

我还是喜欢Rust/Java的使用枚举类型的语句Gender.MALE，而不是go这样又是iota又没有命名空间的枚举
-->

<i class="fa fa-hashtag"></i>
编译时不检查unused的变量/函数

我个人还是很喜欢Rust语言严格的unused检查

---

在下一篇文章中，我再仔细研究/分析Go的杀手锏——channel
