# Lazy static技术

在Java里LazyStatic约等于单例模式，但在Rust中又不完全是。我很喜欢SyncOnceCell

以下是某知乎用户对Java单例模式设计模式的吐槽

```
懒汉、饿汉、双重校验锁、静态内部类

延迟加载问题、多线程的单例模式问题

Java把其它语言用指针/闭包就能做到的事情 抽象成更复杂的「设计模式」...

https://www.zhihu.com/question/391694703/answer/1207383438

你不会真的认为Java中那中全是boilerplate code的单例模式是什么值得借鉴的语言精华吧，

那不过就是成功克服了别的语言中不存在的困难而已。

还有很多人，一个例对象的创建搞的那么复杂，各种锁，double check。那如果真的有这种需求，

是不是最起码得保证单例对象的各种操作也是线程安全的，不然也没法用在多线程的场景，有什么意义？

那随便调用一下一个方法，开销就比创建对象大了，搞什么double check来优化性能的意义何在？

说白了还是那些低等的语言太惯着使用者了，随便就能让你写出线程不安全的代码。

如果你觉得在Rust里创建一个单例对象很复杂，那是因为它本来就很复杂，其他语言中忽略的潜在错误，你都得显式地考虑，而我也不觉得这是Rust的缺点。

原生方法：全局函数不就可以做到了？一个atomic bool记录是否第一次初始化，如果是，就执行特定逻辑
```

确实对于像Rust这样编译型语言，有指针而且强烈区分了static静态数据区的概念，就没有Java上述的双重校验锁单例等复杂设计

## lazy_static/OnceCell的应用

- 1个或若干个函数内使用的固定正则表达式，例如密码强度校验的业务，这种使用不算单例模式，只是数据运行时加载/懒加载
- 在标准库的io模块，stdout和stdin等都使用了OnceCell，让stdout的文件描述符作为单例模式
- 异步轻量级线程的executor通常也用OnceCell实现，避免了使用者要在main函数定义executor一路传参到所有函数，造成不方便

虽说OnceCell方便，但是类似RefCell会有运行时少量额外开销，自己写web服务器的app_state还是老老实实在main中定义用Arc，然后Clone到各个spawn的子线程和web服务器内

我曾经因为滥用OnceCell偷懒不传参，项目中用了50-200个OnceCell，而且好多OnceCell互相依赖，耦合度高，OnceCell之间的初始化要有严格的先后顺序(因为互相依赖)，和RefCell一样完全丧失编译时检查运行时报错

大量的.get().unwrap()代码，心里很慌不知道某个函数调用时依赖的OnceCell是否被初始化

所以我果断重构成app_state模式，main函数中定义，不断往后传参，编译时就能检查全局状态的调用问题，如果能理解main中定义传播下去的思想，也就想明白了为什么标准库一开始就没有OnceCell的API

以下是标准库中唯一使用OnceCell的代码(stdin也类似)，但是标准库都用get_or_init API，没想我啊那样疯狂get().unwrap()

!> Rust的标准库代码没有unwrap()，仅在测试代码和docstring中有unwrap()

```rust
pub fn stdout() -> Stdout {
    static INSTANCE: SyncOnceCell<ReentrantMutex<RefCell<LineWriter<StdoutRaw>>>> =
```