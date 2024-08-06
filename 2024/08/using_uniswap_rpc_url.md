# [白嫖项目方rpc](/2024/08/using_uniswap_rpc_url.md)

用 helius(我了解的唯一支持用u支付) 免费节点进行 ore v2 挖矿频繁 429

只好用 jupiter 的 rpc 结果请求提示 401 原来加上 Origin header 就行了

主要是 helius 一个月要 50u 挖矿一个月都不一定能回本，能白嫖项目方 rpc 就白嫖

```
curl -X POST https://mainnet.infura.io/v3/099fc58e0de9451d80b18d7c74caa7c1 \
-H "Content-Type: application/json" \
-H "Origin: https://app.uniswap.org" \
-d '{
  "jsonrpc": "2.0",
  "method": "eth_getBalance",
  "params": [
    "0x6f5b719dbe7a83bb3dc9b80b5c8a129edac366fa",
    "latest"
  ],
  "id": 1
}'
```

请求 uniswap 前端用的 rpc 如果不加 origin header 会报错

> {"jsonrpc":"2.0","error":{"code":-32002,"message":"rejected due to project ID settings"}}

当然有些 api 的逆向或者爬虫需要 TLS 指纹就更复杂了

爬虫、逆向、改项目方源码 都成为科学家必备技能了

可参考 https://github.com/wangluozhe/requests-go/
