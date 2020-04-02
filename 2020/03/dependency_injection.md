# [依赖注入](/2020/03/dependency_injection.md)

提到依赖注入，可以了解下Spring AOP(面向切面编程?)/IOC

[一个花了40讲介绍dagger2的油管播单，可见作者对dagger2的理解很深](https://www.youtube.com/playlist?list=PLgCYzUzKIBE8AOAspC3DHoBNZIBHbIOsC)

[Dependency Injection of ViewModel with Dagger 2](https://www.techyourchance.com/dependency-injection-viewmodel-with-dagger-2/)

依赖注入的概念是在安卓文档的最后，一个叫「Best Practice」的部分去介绍的

一个类的构造方法的入参中可能需要依赖第二个类，例如new一个Adapter时需要传一个List<DataSet>

[安卓文档](https://developer.android.com/training/dependency-injection)
中对比了使用依赖注入以及不适用依赖注入的写法

<i class="fa fa-hashtag"></i>
Alternatives to dependency injection

服务定位模式(Service Locator Pattern)

## build.gradle

以我的使用或学习经验来说，dagger的下列五个库都用到，不区分androidx和support

```
implementation 'com.google.dagger:dagger:2.24'
implementation 'com.google.dagger:dagger-android:2.24'
implementation 'com.google.dagger:dagger-android-support:2.24'
annotationProcessor 'com.google.dagger:dagger-compiler:2.24'
annotationProcessor 'com.google.dagger:dagger-android-processor:2.24'
```

---

Java依赖注入这块我理解的不是很全面，先停更