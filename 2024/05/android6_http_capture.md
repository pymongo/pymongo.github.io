# [安卓6 VPN方式抓包](/2024/05/android6_http_capture.md)

之前了解的抓包工具都是charles/fiddler居多，但在手机上用都不算好使

android studio新建AVD的时候recommend版本最低都是android7要从上面x86的tab中才能选到android6

android7以上模拟器的网络连接走的是AndroidWifi长按wifi名字可以修改proxy设置，能连charles代理但安卓7非root不能改根证书在全员https年代等于抓不了包

android6以下虚拟机网络没有wifi走的是Cellular蜂窝数据，在蜂窝APN设置里面proxy似乎没有用连不上charles

看StackOverflow有人支招用 adb shell 设置下全局的 http_proxy 环境变量，结果报错 can't connect to proxy

> PS C:\Users\w\AppData\Local\Android\Sdk\platform-tools> ./adb shell settings put global http_proxy 192.168.3.22:8888

有同事说安卓IOS都能用VPN的方式一个应用套壳抓取另一个应用的流量

我试了下httpcanary,安装根证书->选择监听的app->开启VPN->开启被监听的应用->回到canary看抓包

很好用 wss/https 的请求数据全都看到了

HttpCanary很贴心的提示说安卓7以上不能改根证书了 此外类似的应用gpt还推荐Packet Capture,NetGuard
