# [clash bind 0.0.0.0](/2023/07/clash_bind_0.0.0.0.md)

加一行配置 `bind-address: "*"` 星号换成 0.0.0.0 也行

不过让我费解的是同样的 yaml 文件在我 Manjaro 系统上能翻墙但是在 ubuntu20.04 机器上步行

然后我用 curl 测试代理是否工作

> curl -L -v --insecure --proxy http://127.0.0.1:7890 openai.com

在我机器上正常返回 200 但在 ubuntu 机器上返回 502 clash 没生效

于是我想了两个解决方案让那台机器能翻墙调用 openai 接口

## 使用 openai-proxy 代理

缺点是密钥泄漏风险以及每分钟五次请求都频繁 429 too many request

结果这个镜像站用了没过几天也被墙了

## ssh -R 转发本地代理端口

有点不可靠
