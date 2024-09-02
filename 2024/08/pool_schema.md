# [三盘理论笔记](/2024/08/pool_schema.md)

## 机枪池
不局限于挖取某一特定币种，而根据收益情况在使用相同挖矿算法的币种间来回切换的矿池，类似发明者量化提供策略平台那样，平台提供多种不同收益的策略

或者叫 leverage yield, yield farming

- sui: mole.fi
- solana: nx finnance, rate-x
- eth: yearn.fi,pendle

## LST 循环贷
ETH质押得到stETH, stETH在AAVE上面抵押借出ETH(可能抵押率80%以下) 如此循环贷

可以 naive token 作为抵押物撬动链上高收益杠杆

## dune和uniswap
web3最好的社交应用socialfi是 dune 提供链上数据dashboard付费订阅别人数据或者社区论坛那样的项目投研分享寻找alpha 数据=钱

web3最好的gamefi是 uniswap 赢钱的pvp竞争和未知不确定性最强

## 更多defi产品

- 无预言机借贷平台: x.com/ajnafi
- Unibot: 表面是个工具，实际上是一个潜在的集体做市工具，更好的对齐庄的意图（或被庄对齐）(做市成本+退出成本)
- house edge 庄家优势比例，例如0.5%表示每100交易量庄家可能赚的0.5，这个指标太高散户老输就没人玩

对于散户，你要坚信世界就是个草台班子，哪有什么这神那神，一切不过是意为成功之后的草率归因与人工造神。理解技术，但不要信仰技术的叙事：技术有什么潜力能用来做什么不重要，能被庄现在用来做什么才重要。在趋势里押注对庄控制成本有利的生态，跟会搞分发的玩

开发者最大的悲哀就是陪伴渣男生态。不要被技术洗脑，不要过度思考生态能用来做什么，多想这个生态能为你做什么。不要在生态一声声”buidler"中迷失了自己。不要幻想自己龙傲天能为一个基建生态改命。它的命运其实早已被核心团队和叙事注定

记住，部署合约那一刻，你就是庄

## 三盘理论推文highlight

```
分红盘/矿机盘(filecoin,gamefi,io),互助盘(meme/LP),拆分盘

分红盘 一次性投入资产然后线性获得收益

买矿机或者gamefi创世NFT 这样流动性很差
复杂点的是restaking质押六个月获得eigen的收益如果低于eth币本位无风险套利 这部分成本就是矿机

电费:gamefi体力或者装备寿命 项目方可动按时间的线性收益产出

币价和矿机价格飞轮效应 矿机越来越贵

互助盘相比分红盘 投钱立即能看到收益远高于分红盘缓慢赚钱.21

互助盘要风控清算门限
LP投入后要有赚钱上限 要有出局机制 例如最多让你投100赚100要复投 不可能defi summer那样年化10万
套利漏洞 例如二池挖矿 挖空二池
出金秩序
终极互助盘就是赌场

攒(cuan)局 铭文公平发射 低效率的OTC换手 项目方自成交一次轻松拉盘

抛开什么“共享安全”“DA层“之类无用的大词，Restaking本质上是以太坊质押的"P2P"。用户将ETH或LSD版本的ETH质押到“共享安全性”的协议中，赚取租金。用户能够同时享受LSD的收益和再质押的收益，Restaking首先是一个互助盘的逻辑，泡沫源于被质押ETH的机会成本。举个简单的例子，如果ETH质押了LSD，LSD又质押了LRT，当LSD节点和LRT(Liquid Restaking Tokens)质押节点同时因为作恶被扣钱，一份钱怎么被两份扣？这里面是不是相当于上杠杆了

因此ETH的筹码分散度远高于SO 集中在jump/FTX等大户 sol基金会给项目站台(在eth原教旨主义中认为是贿赂)

restaking和lsd的主要目的是鎖定某個幣的流動性，然後在lst/lrt上面疊加被動收益。這樣的話這個幣就會更少的被投入到鏈上的交易中。LST/LRT並不能被作為quote token，所以不可能用他們來起拆分盤，所以這樣的項目對於鏈上流動性是淨抽離。越火鏈上狀況越差
```

- [01 铭文低效率OTC交易为何反而是优势](https://x.com/thecryptoskanda/status/1725276441812832617)
- [分析 FriendTech, Restaking](https://x.com/thecryptoskanda/status/1748841310520557643)
- [Restaking 拆解](https://x.com/thecryptoskanda/status/1748995171432485203)
- [meme政治化(联想到非洲非遗手艺人meme)](https://x.com/thecryptoskanda/status/1769890430009917603)
- [为什么base坐庄比sol便宜](https://x.com/thecryptoskanda/status/1774113651596947525)
- [pumpfun为什么是菠菜工业革命](https://x.com/thecryptoskanda/status/1812608991597679050)
- [cex流动性为什么慢慢转到链上](https://x.com/thecryptoskanda/status/1823476499841998940)
- [三盘理论分析ETH走下坡路](https://x.com/thecryptoskanda/status/1829173759976321112)

