# [MEV](/2024/06/mev.md)

一些layer1的量化方式  我记得lxdao有个朋友的博士课题是跟滑点相关，估计有很多滑点相关的套利策略 量化策略吧？
我了解到的关键词有DEX高滑点埋伏，afterrunning，sandwich attacks等

<https://x.com/LXDAO_Official/status/1803032424395501699>

> 跨链 MEV 捕获,最小价值流失

[flashbot](https://foresightnews.pro/article/detail/42395)

[how to prevent prevent bribery - flashbot issue](https://github.com/flashbots/mev-boost/issues/111)

> Flashbots 的核心基础设施是中继器（relay），其作用是收集来自不同参与者网络的交易包，并将它们转发给矿工。中继器可以验证交易的有效性，防止恶意交易的出现。同时，中继器还能帮助矿工更好地利用 MEV，从而提高他们的收益

https://www.jito.wtf/ SOL贿赂验证者


老板想问链上做什么 能盈利的
aptos MEV
如果aptos的MEV不赚钱就转成juipier那样的聚合器赚价差 大单拆分后出现价差套利 然后应用做火了要aptos基金会的钱
dev获利
借贷协议套利


## 工作安排
学习eth经典MEV实现subway的三种池子算法:uniswapV2,V3,稳定币池子
不一定要部署aptos全节点，用rpc也可以，全节点是为了优化获取mempool
去bsc/l2/evm去测试，不交易，只发现价差
下单机，研究uniswap怎样下单，怎样计算