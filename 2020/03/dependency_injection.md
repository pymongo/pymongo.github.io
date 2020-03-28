# [依赖注入](/2020/03/dependency_injection.md)

依赖注入的概念是在安卓文档的最后，一个叫「Best Practice」的部分去介绍的

一个类的构造方法的入参中可能需要依赖第二个类，例如new一个Adapter时需要传一个List<DataSet>

[安卓文档](https://developer.android.com/training/dependency-injection)
中对比了使用依赖注入以及不适用依赖注入的写法

<i class="fa fa-hashtag"></i>
Alternatives to dependency injection

服务定位模式(Service Locator Pattern)

## build.gradle

> AndroidX

```
implementation 'com.google.dagger:dagger:2.24'
implementation 'com.google.dagger:dagger-android:2.24' // (androidx libraries)
annotationProcessor 'com.google.dagger:dagger-compiler:2.24'
annotationProcessor 'com.google.dagger:dagger-android-processor:2.24'
```

> AndroidX

```
// 存疑，还没试过
implementation 'com.google.dagger:dagger:2.24'
implementation 'com.google.dagger:dagger-android-support:2.24' // (support libraries)
annotationProcessor 'com.google.dagger:dagger-compiler:2.24'
annotationProcessor 'com.google.dagger:dagger-android-processor:2.24'
```