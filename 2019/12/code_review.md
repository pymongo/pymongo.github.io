# [2019年下旬的codeReview总结](/2019/12/code_review.md)

## HTTP请求一定要加Timeout参数

如Ruby的HTTP请求库HTTParty，如果不加timeout参数

则会使用ruby默认的网络请求timeout(30秒或60秒)

而且有些实时性特别高的请求，如股票下单，timeout要设为极小如0.1秒

## 接口的desc文档说明尽可能详细

我从PC端复制过来的币币交易移动端接口，安卓和IOS的同事都来问我"这个source入参是什么意思？"

安卓的同事拿着原型图问"这个ListView委托量和已成交量分别要取接口的哪一个返回值"

如果写接口时我就在文档说清楚有歧义的入参和返回值，就能提高团队的开发效率了

## [guard statement](/2019/12/guard_statement.md)
