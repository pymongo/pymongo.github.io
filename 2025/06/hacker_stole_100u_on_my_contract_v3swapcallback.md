# [我合约被盗360u](/2025/06/hacker_stole_100u_on_my_contract_v3swapcallback.md)

https://x.com/ospopen/status/1931540343612473380

A->B的交易中 v2是用户先转A给池子 而v3则是池子先转B给用户在合约自定义回调中 用户需要转A给池子

这样有点蠢 黑客可以直接调用 pancakeV3SwapCallback 转走用户资金

合约有两个 external 函数 一个是 pancakeV3SwapCallback 另一个是 buy

pancakeV3SwapCallback 我做了鉴权 仅允许 usdt_zkj 池子调用

而 buy 函数没用做白名单检查导致被黑客调用 池子转ZKJ给黑客 我转USDT给池子
