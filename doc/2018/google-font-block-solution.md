# 谷歌字体库被墙的解决方案

## 博客引用的谷歌字体库被墙

我博客https://pymongo.github.io 用的是docsify框架, docsify框架拷贝了在**vue**文档的css, 而vue.css中有这么一行:

> @import url("https://fonts.googleapis... (以下简称为"google字体网址")

由于带google的域名都被墙, 加载google字体网址常常等到TIMEOUT

考虑到除了读者我还希望猎头/HR能看到我博客, 觉得我技术不错提供些工作机会, 但是很多HR/猎头都不会翻墙啊

## google字体网址的含义

google字体网址的完整网址是

https://fonts.googleapis.com/css?family=Roboto+Mono|Source+Sans+Pro:300,400,600

先看各特殊符号的含义: css?是常见的HTTP参数开始标志, +表示空格, |表示逻辑和

请求的是Roboto Mono和Source Sans Pro字体的300,400,600三种线宽

font-weight默认是400, 所以没必要写成Roboto+Mono:400|Source...

## 分析其中一个@font-face

```css
/* greek */ /* 表示font-family Unicode的希腊字母部分 */
@font-face { // 定义新的font-family
    font-family: 'Roboto Mono';
    font-style: normal;
    font-weight: 400;
    src: local('Roboto Mono'), local('RobotoMono-Regular'), url(https://fonts.gstatic.com/s/robotomono/v5/L0x5DF4xlVMF-BfR8bXMIjhIq3-OXg.woff2) format('woff2'); /* 先看系统本地有无该字体再请求 */
    unicode-range: U+0370-03FF; /* 表示font-family Unicode的希腊字母部分 */
}
```

## 解决方案一:中科大镜像

[中科大提供的字体库镜像](https://lug.ustc.edu.cn/wiki/mirrors/help/revproxy)

[总结一下各大CDN - v2ex](https://www.v2ex.com/t/320418)

缺点: 无法离线使用

## 解决方案二:看vue是如何解决的

vue英文文档和docsify文档一样, 没有去解决谷歌字体库被墙的问题

看看vue的中文文档是如何解决的

![google-font-block-solution](google-font-block-solution.png "google-font-block-solution")

通过Firefox的字体工具发现vue中文文档的谷歌字体是

提前放在自己服务器上的, 参考[vue中文文档的github项目](https://github.com/vuejs/cn.vuejs.org/tree/master/themes/vue/source/fonts)

```css
/* 这是styl文件 */
@font-face
    font-family: "Source Sans Pro" /* styl这里没有分号 */
    src: local("Source Sans Pro"), url(/fonts/Source_Sans_Pro/SourceSansPro-Regular.ttf)
```

我很好奇styl文件编译成css后, 居然能把字体等静态文件资源路径给改变了

应该是有配置文件去管理生成后的静态资源路径

## cdn.rawgit.com被墙

我代码高亮使用的cdn.rawgit.com被墙才难搞, 网上用的人少, 没解决方案或镜像

暂时性的办法是 cdn.rawgit -> raw.githubusercontent, 毕竟github早晚被墙
