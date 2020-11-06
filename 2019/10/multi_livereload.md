# [同时热重载(livereload)多个网页](/2019/10/multi_livereload.md)

## 需求

在飞机上，没有网络的环境下，

1. 用docsify服务器开着我的个人博客
2. 同时用gitbook打开大师的多个教程
3. 还能离线打开vuejs的技术文档

You already have a server listening on 35729
You should stop it and try again.

## livereoad的35729端口问题

grunt的live-reload(热加载)默认使用35729端口, 也叫HMR(Hot module reload)

当我已经启动一个热加载服务器时，再去启动gitbook会报错

```
You already have a server listening on 35729
You should stop it and try again.
```

## docsify指定livereload端口

根据[某个issue](https://github.com/docsifyjs/docsify-cli/issues/51)指出了docsify-cli官方文档都没有列出的隐藏参数

> docsify serve . -p 3000~4999 -P 35700 --open


## gitbook指定livereload

发现gitbook命令参数的英文资料很少，[参考资料](https://stackoverflow.com/questions/28789420/how-to-change-default-listening-port-when-use-gitbook-to-serve-a-site)

> gitbook --lrport 35710 --port 4001 serve

我建议是先联网serve一次完成编译gitbook所需依赖

!> 如果希望修改 md 文档也能热重载，网页端口要在 3000-4999 之间

## vuejs.org的技术文档

vue的文档使用的是hexo框架，没有热重载的功能，不用担心热重载端口冲突

```
git clone https://github.com/vuejs/vuejs.org
cd vuejs
npm install
npm start -- -p 4000
```

通过--给npm start传参数的语法跟gem指定参数安装mysql很相似

## ~~没找到修改vue热重载端口的方法~~
 