# [永续合约](/2023/10/perpetual_futures_contract.md)

perpetual swap == perpetual futures contract

为什么交易所的期货清一色都是必带杠杆的永续合约，像Gate所带交割合约

做量化的基本都是做永续合约，永续的每日交易量比现货高几个数量级。此外就是小众点的理财产品和期权交易(例如我妈在币拓打新被人忽悠在期权市场高价买期权开盘破发被套牢好几万)

## 标记价格
标记价格是交易所根据现货行情等因素算出的价格，平仓爆仓用的都是标记价格 `为避免不必要的强行平仓和打击市场操纵，交易所使用标记价格判断用户强制平仓，而非最新市场成交价`

## 正向/反向/双向
目前只学一种 u本位 的 btcusdt 永续中，计价和结算货币都是u，基础货币是btc，因此买(做多)卖(做空)的单位都是btc，杠杆借钱的单位也是btc

在gate所中，永续下单数量单位是多少**张**合约，一张合约是万分之一个btc

反向/双向 合约应该是两个币种的钱包都会变，新手暂时跳过

## 保证金计算
保证金类似于现货交易的冻结金额

gate所平仓手续费=0.075%, 杠杆倍率=125, 风险限额=1, maintenance_rate=0.004(1/杠杆倍率*2)

用两万价格下数量万分之一个btc，订单金额是2u也就是仓位是两u

`维持保证金=仓位*(1/杠杆倍率*2+手续费)= 2/125+2*0.00075 = 0.0175`

初始保证金=仓位*(1/杠杆倍率  +手续费)

Reference: <https://www.gate.io/zh-cn/blog_detail/351/calculation-of-maintenance-margin-classification-of-contract-types>

## 全仓/逐仓保证金
!> 初始保证金仅适用于全仓

默认是逐，意思是单个币种交易对强平的时候不会借用其他币种钱包去强平，每个交易对都是隔离开的

## 资金费率
一种机制，用于保持合约价格与标的资产（如比特币）的实际价格接近。资金费率在永续合约中的作用是在多头和空头之间平衡利益，以避免合约价格与标的资产价格出现较大的偏离

资金费用每 8 小时收取 1 次，如果资金费率为正，则由持多仓者付给持空仓者。如果资金费率为负，则由持空仓者付给持多仓者。资金费用 = 仓位价值 × 资金费率

## 仓位逻辑

### 双向持仓
单向持仓比较简单，当前持卖空仓，开买多仓的下单会减少空仓数量，如果空仓数量减成负数就变成多仓

双向持仓的话，buy/sell + long/short 两个状态可以组合出四种下单方向: 开多、平多、开空、平空

但是在币安下单接口中，如果双向持仓时空仓仓位为零 下单参数 side=buy&position_side=short 会报错 ReduceOnly Order is rejected 意思是你当前

### 开仓/加仓
- 当前仓位为零，下开仓单意思为仓位从无到有是开仓
- 当前仓位大于零下开仓的意思为加仓

### 平仓/减仓

### 开仓要成交后才有仓位
所以交易所的合约/杠杆交易都是默认用市价去开多开空，状态转移: 下单->pending_orders->有成交后->当前仓位

## 寸头
寸头”是一种常用的术语，它表示交易的最小价格变动单位，例如是一张合约等于千分之一个btc

## 头寸
约等于持仓

---

## 下单分布
```
拟合出下单分布的作用是帮助交易者了解和分析市场参与者的下单行为，以制定更有效的交易策略。下单分布是指在特定价格区间内的订单数量分布情况。

通过拟合下单分布，交易者可以获取以下信息：

市场参与者的偏好：下单分布可以揭示市场参与者在不同价格水平上的偏好。例如，交易者可以观察到是否存在明显的支撑或阻力水平，这有助于他们确定适当的进出场点。

需求和供给：下单分布可以反映市场中的需求和供给情况。通过分析下单分布的形状和变化，交易者可以了解市场中买盘和卖盘的强度与变化，从而更好地预测价格走势。

市场深度：下单分布可以提供关于市场深度的信息，即在不同价格水平上的订单数量。这有助于交易者评估市场的流动性和潜在支撑/阻力水平，以决定交易的规模和执行策略。
```

## 容量限制
做市商高频策略的缺点是容量限制，交易所自己会跑这样的策略，流动性套利大头被交易所吃掉，导致策略投入资金过大的话就是无法成交，也就是下单量有限制叫容量限制

## 滑点
滑点和滑单就是成交价格跟预期价格偏差太大

## 交易尾部置信区间
```
交易尾部置信区间（Tail Risk Confidence Interval）是用于衡量价格波动风险并设置风险限制的概念。它是一个统计概念，用于描述价格变动的极端情况。

尾部是指价格变动的极端区域，通常是远离均值的部分。置信区间是指在一定置信水平下，价格变动可能发生的范围。

在交易中，尾部置信区间用于确定风险限制或风险管理策略。例如，可以设置一个尾部置信区间，表示以一定的置信水平，价格变动可能超出该区间的概率较小。交易者可以根据尾部置信区间来设定止损位或调整仓位规模，从而控制风险并保护资金。

尾部置信区间的具体设置可以根据交易者的风险承受能力、预期收益和市场条件进行调整。较宽的置信区间表示更大的波动范围和风险，而较窄的置信区间表示更小的波动范围和风险。
```

## 跨盘口
在股票交易中，假设orderbook买盘第一档有500数量，第二档有600数量，如果我下一个卖单价格能撮合成交的，就会吃掉所有买盘第一档的单和部分第二档的单，这个现象和行为叫跨盘口吗

在gate上跨盘口开仓会报错LIQUIDATE_IMMEDIATELY如果成交会被立即强制平仓

## ROT
```
Return on Turnover（ROT）是一个常用的评估指标，用于衡量投资组合的盈利能力与交易成本之间的关系。它计算的是投资组合的平均每笔交易盈利与每笔交易成本的比例，通常以百分比表示。

具体计算公式如下：
ROT = (平均每笔交易盈利 / 平均每笔交易成本) * 100

除了ROT指标外，永续合约量化交易系统还有其他常用的评估指标或者指标：

Sharpe比率（Sharpe Ratio）：衡量投资组合的风险调整收益率。它考虑了投资组合的平均收益和波动性，用于评估投资的风险收益比。

最大回撤（Maximum Drawdown）：衡量投资组合在特定时期内从最高点到最低点的最大损失。这个指标可以帮助评估投资组合的风险承受能力。

胜率（Win Rate）：衡量交易系统中盈利交易的比例。它可以帮助判断交易系统的成功率。

平均持仓时间（Average Holding Time）：衡量投资组合中平均持有头寸的时间。它可以帮助评估交易系统的交易频率和持仓策略。
```

但老板说用单位时间内的盈亏除以总成交额，单位是每万分之一就是1bp

## BBO
最佳买卖盘价位（BBO，Best Bid and Offer） 币安下限价maker_only单如果价格出现波动应该是下单价格立马能被撮合，币安就会报错maker only is rejected

---

## stp
stp = self trade protection 防止自买自卖的一些下单设置

## 期权希腊值 PA/BS
ok最佳实践文档中提到的，估计是期权交易相关跟永续合约没关系暂时不用学

---

## 如何学习量化

orderbook深度频道，币安有频率限制，不能一次订阅所有交易对，只能两三个交易对

当前orderbook快照+公共挂单orders,公共成交推送trades, 还原出orderbook时序数据

不一定要实盘，模拟盘，或者用历史数据回测自己策略和因子正确性，

pandas做加密货币因子分析 有个库alphalens (曾经一个量化网站开源出来的)

数据入库，数据组合，

https://github.com/yutiansut/QUANTAXIS/tree/master  量化交易库

金融工程研报，知乎，量化交易库代码，公众号、自己多积累经验去测

研报系列推荐: 研究报告:天风证券-金融工程海外文献推荐第269期-231025