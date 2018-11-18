# 谷歌字体库被墙的解决方案

## 博客引用的谷歌字体库被墙

我博客[pymongo.github.io](pymongo.github.io)用的是docsify框架

而docsify框架拷贝了vue文档的css

而vue.css中有这么一行

@import url("https://fonts.googleapis...(以下简称为*请求地址*)

众所周知的原因域名含google的基本被墙

有同学跟我反馈说, 我博客加载很慢

我测试了下果然是谷歌字体库被墙导致页面一直等待到timeout

网站上线时给别人看的, 我自己能翻墙看别人可不行

## GET请求网址的含义

请求的字体库网址是 https://fonts.googleapis.com/
css?family=Roboto+Mono|Source+Sans+Pro:300,400,600

css?family=Roboto+Mono表示请求Roboto Mono普通字体(font-weight:400)

|表示和, 和Source Sans Pro字体的三种font-weight:300,400,600

font-weight=400是Regular标准字体宽度, 600应该是加粗, 300是偏细

## 请求的@font-face

```css
//截取自请求地址内容的一部分
/* greek */ // 表示font-family Unicode的希腊字母部分
@font-face { // 定义新的font-family
    font-family: 'Roboto Mono';
    font-style: normal; // 可以省略
    font-weight: 400;
    src: local('Roboto Mono'), local('RobotoMono-Regular'), url(https://fonts.gstatic.com/s/robotomono/v5/L0x5DF4xlVMF-BfR8bXMIjhIq3-OXg.woff2) format('woff2'); // local表示查看系统是否自带该字体
    unicode-range: U+0370-03FF; // 表示font-family Unicode的希腊字母部分
}
```

虽然请求了2个font-family, 不过总共有几十个零散的字体文件, 逐个下载下来不现实

## 解决方案一:中科大镜像

[总结一下各大 CDN - v2ex](https://www.v2ex.com/t/320418)

[中科大提供的字体库镜像](https://lug.ustc.edu.cn/wiki/mirrors/help/revproxy)

缺点: 无法离线使用

## 解决方案二:看vue文档是如何解决的

docsify的css基本是复制的vue文档的css

docsify文档/vue英文文档 没有去解决谷歌字体库被墙的问题

好在vue中文文档方便中国用户解决了谷歌字体库被墙

<img src="/img/frontend/vuecn-font.png">

通过Firefox的字体工具发现vue中文文档的谷歌字体是

提前下载好放在自己服务器上的, 参考[vue中文文档的github项目](https://github.com/vuejs/cn.vuejs.org/tree/master/themes/vue/source/fonts)

```css
/* 这是styl文件 */
@font-face
    font-family: "Source Sans Pro" /* styl这里没有分号 */
    src: local("Source Sans Pro"), url(/fonts/Source_Sans_Pro/SourceSansPro-Regular.ttf)
```

我很好奇styl文件编译成css后, 居然能把字体等静态文件资源路径给改变了

应该是有配置文件去管理生成后的 静态资源路径

## 后话:我换成Meiryo字体了

Meiryo虽是日文字体显示中文比雅黑还好看

字体库就用一个Roboto Mono

## cdn.rawgit.com被墙

我代码高亮使用的cdn.rawgit.com被墙才难搞

网上用的人少, 没解决方案或镜像

暂时性的办法是 cdn.rawgit -> raw.githubusercontent

github全家桶迟早会被GFW墙掉 