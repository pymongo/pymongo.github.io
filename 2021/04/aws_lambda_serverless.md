# [AWS lambda serverless](/2021/04/aws_lambda_serverless.md)

Aws 分享

## 什么是 serverless

Aws lambda 就是 serverless

为了更细力度的服务器计算资源的划分

部署不用租服务器，一旦用户请求来了才会 new 一个计算资源/容器/VM（lambda函数）

计算资源是按客户代码运行时才按毫秒，想数据库这种持久的就另外收费

但是容器的隔离不如serverless好

能不能做到当用户情况客户的应用时，毫秒级别的时间就能new一个lambda函数VM去处理请求

一个VM跑一个用户的代码,

broker = 券商

处理请求后再毫秒级关机，qemu或docker并不能达到这种需求

aws这个是


