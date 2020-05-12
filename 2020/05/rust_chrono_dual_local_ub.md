# [chrono不能连用两个local](/2020/05/rust_chrono_dual_local_ub.md)

我用ruby脚本模拟HTTP请求，发送给Rust服务器结果返回接口签名的时间戳已过时。

通过打log的方法发现，rust的时间戳是现在时间的8小时后，

原因是chrono库「两个local连用」。

> chrono::Local::now().naive_local().timestamp()

上面写法会出现UB：希望得到+8时区的时间戳结果返回的是+16的时间戳

我写了个Example证实了连用两次local会导致时区叠加，[源码在Github上](https://github.com/pymongo/rust_learn/blob/master/examples/get_timestamp.rs)

---

因为我在单元测试中也是将这段代码复制到请求的表单中，所以用错误的时间戳发请求，再用错误的时间戳比较，一直没发现问题，直到我用ruby脚本测试时就出错了。

收获是单元测试未必可信，有时需要用其它编程语言写相应的测试/脚本才能进一步验证代码逻辑的正确性。
