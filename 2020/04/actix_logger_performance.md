# [actix日志拦截器对性能的影响](/2020/04/actix_logger_performance.md)

测试方法：编写一个`SELECT * FROM table`的API接口，通过`ab -n 1000 -c 1000`测试性能

关掉所有Logger(日志拦截器)后，每秒能处理1.1万到1.2万次请求，平均请求耗时0.08ms

一旦开启了日志拦截器，平均请求耗时就提高到0.11~0.13了

由于env_logger默认的日志拦截器是UTC+0的时区，所以还得定制日志拦截器格式化输出当前时间

经过测试后发现，光格式化datatime大概要花0.02ms

记录日志是为了追溯/重现UB或报错，如何在记录日志和性能间取得平衡？

actix本身性能优秀，不加日志拦截器每秒能处理1.1万个请求，(0.1ms内完成一次查数据库的请求不是问题)

加了日志拦截器性能就降低到1秒8500次请求，25%~30%的性能损失，有点舍不得这么大的性能损失

## actix vs grape

我试了下ruby的grape+thin服务器，用同样的查询条件查同一个数据库返回同样的json，性能只有1秒完成1600次请求

因此可以得出结论，在单次SQL查询的API接口中，actix(不开日志)比grape的性能要强7~8倍

跑分上没有 techempower.com/benchmarks 上插件那么大

techempower上actix可比grape至少要快50-70倍

不过看在actix至少比grape快5倍的事实上，已经可以让rust重构掉一些grape的项目了...