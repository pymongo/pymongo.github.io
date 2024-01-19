# [部署gpt nextweb](/2024/01/deploy_chatgpt_next_web.md)

之前一直在 use.aihomego.com 用gpt4月会员，今天到期了，一直不爽这种多个人共用多个gpt4账号池，经常会被分配到被限速很慢的账号

于是我还是考虑买一个gpt api key独享账号，顺便对比下比20刀一个月的gpt plus价格哪个更划算

```
docker run --name gpt -p 3000:3000 \
   -e OPENAI_API_KEY=foo \
   -e BASE_URL=https://one-api.xiaobaiteam.com \
   yidadaa/chatgpt-next-web
```

用nginx反向代理略有很多不同和配置，我就暂不考虑

在管理员权限的 windows powershell(admin) 

> New-NetFirewallRule -DisplayName 'Docker port 3000' -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow

这样让本来只能在 localhost:3000 访问 gpt web 暴露在以太网/内网上

最后是去掉防火墙规则的代码

> Remove-NetFirewallRule -DisplayName 'Docker port 3000'

## 必须关闭Auto Generate Title否则扣两次钱

跟官方 gpt web的行为一样，每次问答后，还会将当前会话的所有内容发给gpt动态生成/更新会话的标题，这样导致提问一次会扣费两次，一定要关掉这个没啥用的配置省点钱，目前我才用了两天就花了 1.3$
