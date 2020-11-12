# error handling in Rust

## 大部分标准库的error都可以统一成Result<(), Box<dyn std::error::Error>>

## 偷懒式: anyhow或内置anyhow的tide::Result

## 匠心: 做库或做app要用enum Error枚举/穷举所有错误

## 不可能出错用Infallible(一旦出错自动让warp的recover去捕获处理?)

Infallible的使用参考warp和async-graphql
