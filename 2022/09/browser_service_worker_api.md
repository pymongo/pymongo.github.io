# [browser Service Worker](/2022/09/browser_service_worker_api.md)

在 google colab 和腾讯在线文档这类数据频繁交互的网页应用中，

在 chrome dev tools 的 network 监控中能看到一个齿轮图标前缀的网络请求

[查资料](https://stackoverflow.com/questions/48336926/name-with-gear-icon-in-chrome-network-requests-table#:~:text=The%20gear%20icon%20signifies%20that,to%20populate%20the%20offline%20cache.)
后发现原来是 browser 的 service worker API 技术就会带上齿轮图标

> 随着 web 服务变复杂，js 中耗时间耗资源的运算过程会阻塞单线程的 js runtime, service worker 是单独进程从而解决这个问题

service worker 可以干页面缓存+拦截请求

<https://www.jianshu.com/p/8c0fc2866b82>
