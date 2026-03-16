# [toxic prop amm](/2026/03/toxic_prop_amm.md)

26/03 solnaa基金会研究员发布了一个research指责暗池prop amm通过快速变动 吃用户滑点利润获利

https://x.com/bl8_runner/status/2029639150157152399 trading.solana.com/research/router-timing-games

结果迫于 humidifi 这样暗池做市商机构的压力删帖了，我缓存了文章感兴趣的朋友可以私聊我要

实现方法很多种 例如 quote 的时候 nowms-oracle_update_at_timems=1ms 

然后 oracle price is steal 随着时间越不新鲜就报价就越差

这样 quote buy 链上询价是 100 上链交易 111 很正常 phantom,titan 这些默认滑点都有 1.5% 用户的利益就被做市商吃掉1%滑点

所以 moonshiesty 在推上怒喷这些做市商是 toxic prop amm https://x.com/moonshiesty/status/2029979641625379213
