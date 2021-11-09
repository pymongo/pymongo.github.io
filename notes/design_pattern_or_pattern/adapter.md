# Adapter design pattern

## 作用
android ListView/RecycleView API 的数据源非要是 xxxAdapter

Adapter 主要是 Java Android 代码用的多，Rust 类型系统的抽象能力足以包含 Adapter 功能

## 适配器模式的鸡肋
虽然设计模式跟语言无关，但是我看了那么多代码就只有 Android Java 代码大量用 Adapter 模式，假设列表页面的每行的数据叫model

安卓这边要先用 Adapter 把 model 套进 adapter，然后再 inflate 还是啥的层层抽象才把一个数组的数据渲染成列表

我看 vue 或者 gtk 就直白多了，哪有什么 adapter，直接把数据渲染到列表完了，

同样是 GUI 完全没有那么罗嗦的 Adapter 抽象(当年我写安卓的时候，改下列表页面的数组数据格式，还得改 Adapter 等等好几个结构体真是麻烦

我看也不是 Java 没有 trait 这样的抽象，只不过安卓这些 API 有点过度设计过度抽象了，同为 GUI 渲染列表数组数据的代码，怎么就非要 Adapter 不可

然后 Rust 源码这里除了 std::iter 有个 module 叫 adapter 然后对外 pub use 都隐藏掉这个 adapter 了（感觉 Rust 迭代器往后可以接实现迭代器 trait 的方法即可，没必要叫适配器 Adapter）

Rust 目前只在迭代器中说到往后可以接若干个适配器，实际上不要所谓的适配器抽象也够

所以我说见过那么多项目的代码和语言，有的设计模式例如 Adapter 适配器模式就很鸡肋没啥人用

就好像 redis,etcd 一定要抽象成 KvAdapter 么，直接叫 KvDatabase 不就更易懂么?

## examples
- listView.setAdapter(itemsAdapter); // itemsAdapter instanceOf ArrayAdapter
- library/core/src/iter/adapters/mod.rs // 都在 std::iter 层 pub use 导出，对外看不到 adapter 模块
