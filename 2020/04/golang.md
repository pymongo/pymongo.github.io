# [Go语言学习](/2020/04/golang.md)

最近我在读一些go项目的源码，发现Rust其实借鉴了很多go一些关键词和机制例如`panic`

go和Rust一样自带了benchmark,test,fmt等功能，只不过go的工具丰富程度还不如Rust

我花了半小时看完Go语言的菜鸟教程，初步结论是Go的channel确实让我眼前一亮值得一学，语言语法糖级别的协程

~~我打算以哲学家进餐问题为例单独写篇文章研究下Go的goroutine+channel~~

但是Go语言作为唯一一个暂不支持泛型等高级抽象的主流静态编译语言(说实话Go的一些包袱和兼容性决定Go2的泛型我也不是很看好)，

反而要依赖反射、interface等额外的运行时overhead去实现"泛型"

Go也不支持宏/元编程(codegen的功能可能不能像Rust宏那样从编译原理AST的更细腻的粒度去展开代码)

作为现代化编程语言，Go未免也太大道至简吧，连iterator,for_each,map,reduce,generator等API都没有，

个人感觉可能过于受到C语言之父等老的Unix大牛影响，很多C语言没有但是很重要的迭代器Go也学C语言那样不集成

如果用Go或C做infra倒无所谓，但是做业务CRUD没有map或for_each真的好吗？

## 方法论:如何学习新语言

对于掌握多门编程语言有经验的开发者而言，以下是我认为最佳的学习路线

1. 学习包管理/项目构建工具，例如maven/npm，理解项目文件结构
2. 利用第三方依赖开发一个http client/server，能读写简单的json数据
3. 简单了解下新语言的单元测试和benchmark的使用
4. 去leetcode上找Easy的题做一道
5. 解决哲学家进餐问题，理解新语言在多线程上的应用

> actix-web和gin性能比较

后记: actix-web并不是Rust最快最轻量的Web框架，性能不如tide或warp等，所以不应该拿actix-web去比go

我测试了rust和go star数最多以及最快的框架，用ab -n 1000 -c 200在我本地的mbp2019(i5 8G内存)上的测试结果是

actix(17000)，gin(16500)，iris(21000)

~~没想到Rust star最多的rocket框架性能如此糟糕😰(现在rocket边异步了，性能飞升)~~

由于gin打了log会影响性能，actix和iris都没打，所以gin和actix的性能实际上差距不大

而iris能领先gin/actix 15%~25%的性能，每秒甚至能处理23000个请求(10倍于rails)，实在强悍

我用ab -n 5000 -c 5000通过返回"pong"字符串的接口测试了Rust和Go开启编译器优化后的性能。actix-web每秒能处理25368个请求，Go-iris能处理25787个请求。

Rust从Debug版编译换成release版编译加上一些编译优化后，性能从1.7万提升到2.5万，而Go只是从2.2万提升到2.5万

> Go语言最快的iris框架开启编译器优化后的速度

![](go_iris_benchmark.png)

> Rust语言开启release版本编译后的速度

![](rust_actix_benchmark.png)

Rust编译器选项里可以把默认的内存管理器换成FreeBSD的jemalloc或者微软的mimalloc，具体效果如何我没尝试了。

我mac电脑ab命令最多开到5000并发，开1万或2万并发会提示socket地址不够用了，可能我之前不小心用chown改了文件权限，也可能是端口本来就不够用，所以测试结果仅供参考

## Go包管理工具(go mod)

在官方没有推出go-modules包管理工具时，有一些第三方的包管理解决方案，如go-vendor

不过go-modules感觉不如gem/maven/npm等其它语言的包管理好用，更比不上cargo

> go mod init go_http_client

会生成一个go.mod的文件

在main.go中添加`import "github.com/gin-gonic/gin"`(Go知名Web服务器)后

执行`go mod tidy`会自动将依赖下载到`GOPATH/pkg/mod`中

此时go.mod文件多了一行`require github.com/gin-gonic/gin v1.6.2`

还多了一个go.sum文件(类似package.json-lock)

如果希望将项目依赖的包移到项目文件夹内，可以使用`go mod vendor`。

## Go项目构建

[golang-standards/project-layout](https://github.com/golang-standards/project-layout)

我非常喜欢Rust语言在一个项目里能编译多个bin(可执行文件)，以及多个examples的特性，写完一个函数就能直接运行的爽快体验

[How to structure Go application to produce multiple binaries?](https://stackoverflow.com/questions/50904560/how-to-structure-go-application-to-produce-multiple-binaries/50904959)

[golang 的编译没有 debug release 之分吗？](https://www.v2ex.com/t/561636)

> go build -o ${output} {source.go}

---

## Go语言吐槽

我还是比较欣赏Go会对unused variables/import给出编译错误，但是Rust那样可以通过配置unused警告是否升级为Error更灵活

- Go无法拿到/直接控制naive/o thread，中间多了层Go调度器实现os thread和协程的调度，协程数量多时，协程间上下文切换开销可能会很大
- GC机制对「非GC友好的pattern/数据结构」例如TiKV底层的LSM tree在在内存中有个类似LRU小对象的缓存池，小对象会经常换入换出使得GC的压力很大
- 没有迭代器、生成器、map、for_each、reduce等函数式API(for_each/map是写业务代码数据转换的极其重要API，例如将结构体map为json/protobuf之类的)
- 字符处理不统一，没有统一成Unicode(没有处理C语言遗留的w_char问题)
