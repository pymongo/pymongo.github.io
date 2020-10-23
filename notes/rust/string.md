# &str/String in Rust

&str -> String有性能开销，反之则没有

## 为什么Rust不允许index of String

Rust的字符串Slice实际上是切的bytes。这也就造成了一个严重后果，如果你切片的位置正好是一个Unicode字符的内部，Rust会发生Runtime的panic

不同的Unicode字符的长度可能不一样，Rust的String的内存模型是u[8] bytes，String只是说明这串u8是合法的UTF-8编码

「并没有携带u8数组组成了多少个字符，也没有携带该如何分割bytes去组成字符」String的len()方法仅仅是返回u8数组的长度

需要迭代一遍字符串才能知道一共有几个Unicode(每个字符长度可能是1,2,3,4)

所以对u8数组构成了几个Unicode字符充满未知的情况下，冒然去索引字符串是不可能的而且不安全

一定区分从Rust和Python字符串的内存模型，Rust字符串的u8数组不像Python，是没有足够的信息量去索引
