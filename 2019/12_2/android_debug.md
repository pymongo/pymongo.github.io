# [Android Debug](/2019/12_2/android_debug.md)

<i class="fa fa-hashtag mytitle"></i>
debuggable true

[谷歌的教程](https://developer.android.com/studio/debug)讲解了如何Enable Debug

在`app/build.gradle`的android->buildTypes->release中

添加上<var class="mark">debuggable true</var>

## 开关代理可能导致无法Debug/连虚拟机

Debug和AVD虚拟机都是通过socket与AS连接

如果开着AS的途中网络代理发生变化，会导致无法Debug或连接AVD

## Do Not Step into Library

idea并没有像VisualStudio的`just my code`的单步运行机制

虽然idea3.0在stepping配置选项中提供了：Do not step into Library code

但不好用，而且AS版本一般落后idea一个版本，如AS还在191.x(2019.2之前)的版本时idea已经是193.x(2019.3.1)了

## Exception断点

是我一直想要却不知道的功能，快速定位到各种空指针附近的代码  
