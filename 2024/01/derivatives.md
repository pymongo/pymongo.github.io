# [derivatives](/2024/01/derivatives.md)

(24年第二个周末摆烂熬夜玩竞技游戏，结果半夜心脏疼右手抚在心脏上，以前是半夜肚子疼抚肚子，第一次抚摸心脏，这应该身体最后给出的不良信号了，下次再糟蹋心脏真就猝死了。本身慢性心脏病果然还是不要玩拼反应操作的激烈PVP/PVE对抗游戏，这样肾上腺心跳猛增但四肢毫无运动的游戏很伤心脏，还是只能玩棋牌智力策略休闲游戏。别玩游戏学点东西吧！)

## 什么是衍生品

在传统金融市场中，“衍生品”是指一类金融工具的总称，其价值源自其基础资产的价格变动。衍生品可以基于各种类型的资产，包括股票、利率、商品、货币、指数等。以下是几种传统市场中常见的衍生品类型：

1. **期货合约（Futures）**：这是在未来的特定日期按照今天确定的价格买卖特定数量的资产的标准化合约。期货合约通常在交易所交易，涉及的资产包括商品、金融工具等。

2. **期权合约（Options）**：期权合约给予持有者在未来某个时间点以特定价格买入或卖出基础资产的权利，但不是义务。期权分为看涨期权（Call Options）和看跌期权（Put Options）。

3. **掉期合约（Swaps）**：这是两方之间的协议，同意在一系列未来时间点交换资金流。最常见的掉期类型是利率掉期，其中一方支付固定利率，而另一方支付浮动利率。

4. **远期合约（Forwards）**：远期合约类似于期货合约，但它们是非标准化的，并且通常在场外（OTC）市场进行交易。远期合约的条款可以根据双方的需求量身定制。

衍生品的存在是为了各种目的，包括对冲风险（Hedging）、投机（Speculation）、获取杠杆（Leverage）等

衍生品市场是金融市场的重要组成部分，为市场参与者提供了风险管理和**价格发现**的手段。

## 衍生品如何锚定标的价格

> Q: 除了加密货币有资金费率去缩小两个市场同一商品的价格，在其他金融领域，例如标普指数和标普指数基金之间，会不会有类似的机制缩小二者价格差距

在传统金融市场中，虽然没有加密货币合约交易中的“资金费率”这一具体机制，但存在其他形式的机制来保持衍生品价格（例如期货、期权）与其标的资产（比如标普指数）之间的一致性。对于标普指数和标普指数基金之间的价格关系，以下是几种主要的机制：

1. **套利交易**：套利者会利用不同市场之间同一商品的价格差异来实现无风险利润。如果标普指数基金（如ETFs）的价格偏离了标普指数的实际值，套利者将买入低估的资产同时卖出高估的资产，直到价格差异消失。例如，如果某只标普指数ETF低于标普指数实际值，套利者可以买入这只ETF，同时在期货市场做空S&P 500期货合约，待价格一致时再同时平仓以获利。这样的买卖行为有助于将ETF价格拉回到与标普指数更加一致的水平上。

2. **创红机制**：许多交易所交易基金（ETFs）拥有一种“创红”机制，即授权参与者（APs）可以直接与ETF进行交易，以“创造”新的基金份额或“赎回”现有的份额。这使得当ETF价格偏离其净资产值（NAV）时，APs可以通过创红机制调整ETF供应量，驱动其市场价格回归到净资产值附近。

3. **期现套利**：对于期货市场而言，期货价格和现货价格之间的差异受到基差（即现货价格与期货价格之间的差价）的影响。交易者会进行期现套利以确保期货价格反映其到期时的预期现货价格，这一机制也有助于缩小两市场价格之间的差距。

4. **资金的流动性**：在一个有效率的市场中，资本会流向收益率更高的地方。如果某个标普指数基金的价格低于指数，投资者可能会选择这个更便宜的投资途径，从而推高其价格；反之，如果价格高于指数，则投资者可能会卖出，推低其价格。

黄金衍生品（如期货合约）的价格与现货价格之间的关联被称为“基差”（Basis），基差就是衍生品价格与现货价格之间的差异。以下是几个关键因素和机制，它们确保黄金等商品的衍生品价格与现货价格保持一致，尤其是在交割合约接近结算日期时：

1. **套利机会**：如果衍生品（如期货）的价格与现货价格之间存在显著差异，套利者会进入市场来利用这种价格差异。他们会买入低价的一端并同时卖出高价的一端，直到价格差异被消除或缩小到交易成本以下。

2. **交割机制**：期货合约在到期时允许或要求交割实物黄金。这意味着，随着合约到期日的临近，持有期货合约的交易者必须决定是实际交割黄金还是平仓合约。为了避免交割的成本和不便，许多交易者选择将他们的头寸平仓，这通常会导致期货价格向现货价格收敛。

3. **成本与携带费用**：衍生品价格通常会反映持有或存储现货商品直到未来某个日期的成本，这被称为“携带费用”（Carry Cost）。携带费用通常包括存储费、保险费、资金成本等。在理论上，期货价格等于现货价格加上携带费用。当期货合约接近到期时，携带费用降低，因此期货价格趋向现货价格。

4. **市场深度和流动性**：一个具有充足流动性和市场深度的交易市场会增加交易频率，从而有助于价格发现机制的效率，使得价格偏差不会持续存在。

5. **价格发现过程**：由于期货市场经常被用于价格发现，市场参与者利用所有可用信息来决定合约的价格。随着时间的推移，这些价格会更准确地反映市场对现货黄金的需求和供给情况。

6. **期货合约的标准化**：期货合约是标准化的，这意味着交割的时间、地点、数量和质量等都是事先规定好的。这种标准化有助于减少不确定性，从而使期货价格更紧密地跟随现货市场。

## 中行原油宝爆仓亏百亿

2020年4月,全球油价出现历史性的暴跌,美国西德克萨斯中质油（WTI）期货价格首次出现负值,最低触及-40美元/桶左右。这种情况确实是由于持有原油的存储和运输成本暂时性地大于了原油本身的价值。以下是导致这种现象的几个原因：

1.**存储能力有限**：全球石油储存设施接近满载。由于新冠疫情导致的经济活动下降,石油需求急剧减少,同时产量未能及时减少以配合需求下降,导致供大于求。当存储空间不足以存放过剩原油时,实物原油的持有者可能不得不支付高额费用来储存或运输石油,或者急于处置手中原油,即使是以负价格出售。(想起来疫情导致码头/货车司机停工仓库满)

2.**期货合约的交割机制**：发生负价格的是5月交割的WTI原油期货合约。在期货合约即将到期时,持有合约的交易者通常需要决定是否实物交割。由于当时储存空间稀缺,许多持有期货合约的交易者（尤其是那些并不打算实际接收原油的投机者）发现自己无处存放即将交割的原油。在这种情况下,他们不得不以任何价格卖出合约,即使是负价格,以避免实物交割的困境。

3.**疫情导致的需求萎缩**：COVID-19疫情导致的封锁和旅行限制减少了对石油的需求。航空公司和其他交通工具减少使用石油,工业生产和消费者活动也下降。

4.**技术性卖盘**：在期货合约到期前,许多持有期货的投资者可能通过卖出合约来避免实物交割,这种技术性的卖盘进一步推低了价格。

因此,原油价格暂时性的负值反映了极端市场状况下的供需失衡以及存储和运输资源的紧缺。这种情况非常罕见,显示了原油市场在特定时刻的异常状态。对于那些不准备或无法承担实物交割的交易者而言,他们更愿意支付费用以卸掉风险,而非实际接收原油。这就是为什么价格可以为负数,即出现了“付钱请人带走油”的现象。原油价格为负数存储成本大于开仓成本

### 移仓

将即将到期的期货合约的持仓平仓，并开立一个较远月份的同类合约的新仓位的行为

## 为什么国内金融市场被批评不够开放

关于某些媒体批评中国的金融制度不够开放，这往往是基于对中国金融市场相对于其他国际金融市场的一些特点和政策的观察。以下是几个方面的考虑：

1. **市场准入限制**：国际投资者在中国市场的参与通常受到一些限制，包括资本账户管制、投资额度限制、资格审批程序等。这些措施可能会影响国际投资者进入市场的效率和积极性。

2. **资本流动控制**：为了维持金融稳定和防止资本大量流出，中国有较为严格的资本流动管制。这可以限制资金的自由流入流出，从而减少中国金融市场与国际市场的互动。

3. **汇率管理**：中国的汇率并非完全由市场力量决定，中国人民银行通过日常干预在一定程度上影响人民币汇率，这被一些国际观察者认为是对市场的限制。

4. **监管环境与透明度**：中国的监管框架和市场透明度在持续进步，但某些国际投资者和机构可能仍然觉得与他们熟悉的其他国际金融中心相比存在差距。

以上海能源交易所（INE）的原油期货交易相比美国交易所，一些差异包括：

- **市场成熟度**：INE相对较新，成立于2018年，而纽约商品交易所（NYMEX）已有数十年历史，市场参与者更加多样化和成熟。

- **交易量和流动性**：INE的交易量和流动性正逐步增加，但由于市场新兴和参与者相对较少，通常仍然低于NYMEX等成熟市场。

- **国际参与度**：尽管INE允许国际投资者参与，但由于上面提到的诸多因素，国际投资者参与度可能不如成熟市场。

- **产品种类和衍生工具**：成熟市场如NYMEX提供丰富的衍生品和服务，而新兴市场可能在产品和服务的深度和广度上还在发展阶段。

- **市场监管和开放度**：中国市场的监管政策、交易规则、资本控制等可能较为复杂，对于习惯于其他国际市场的投资者来说，可能需要更多时间去适应。

总体而言，中国的金融市场正逐渐开放，如通过推出沪港通、深港通等机制来允许更多的跨境资本流动，而上海能源交易所的原油期货的推出是这一过程的一部分。随着市场开放的深化和监管环境的改进，预期这些差距会逐渐缩小。

## 价格发现

价格发现是市场机制中的一个过程，它涉及到买家和卖家通过交易活动确定资产（如股票、债券、商品、货币等）的市场价格。英文术语为 "Price Discovery"。

在量化交易中，做市商（Market Makers）通过提供买卖报价，帮助确立某个资产的市场价格，从而参与到价格发现过程中。由于做市商需要同时提供买卖报价，他们在市场上的行为对于形成公认的资产价值至关重要。

双交易所价差套利（Arbitrage）也是价格发现的一个重要组成部分。当同一资产在不同交易所出现价格差异时，套利者会同时在价格较低的市场购买该资产，在价格较高的市场出售，通过这种策略，套利者有助于两个市场价格的一致性，因此也是参与价格发现的一个重要力量。通过套利活动，市场上的价格差异会减小，最终使得资产价格在不同市场之间趋于一致，这一过程也是价格发现的体现。

## 币本位资产增值

<https://twitter.com/BTW0205/status/1742016934961655865> 

ok上面金融理财/余币宝(其实就是现货借币给别人借贷宝一样吃利息)2024年初都干到60%年化收益了；看看我招商银行20w的存款日利息12块，ok上我存了两千块不到就每日5.6块利息了，就算刨除u换rmb有九折的中间商赚差价，也有几十倍于朝朝盈的收益

持有非u非法币的币，可以通过杠杠交易借贷给别人，质押验证者节点，Defi流动性挖矿质押获利，而且还不用像合约那样要法币频繁开仓平仓收手续费

Q: 加密货币量化交易中往往考虑的都是法币也就是usdt的增长当成唯一的收益，可是我能不能换另一个角度，币本位的角度思考收益？例如我可以将eth质押获取收益，而非要将eth平仓成usdt美元也就是法币才有收益？如果我的eth等 加密货币的数量能增长也是一种盈利

#### 币本位的例子：
- **质押收益**：将ETH或其他可质押的加密货币进行质押，从而获得额外的币种作为奖励。
- **矿池挖矿**：参与挖矿池，通过贡献算力来挖矿，获得的新币增加了你的币本位资产。
- **提供流动性**：在去中心化金融(DeFi)平台提供流动性，赚取交易费用或其他代币作为奖励。

### 币本位的优势：
- **对冲法币通胀**：如果你认为长期内加密货币将比法币更有价值，那么币本位可以作为对抗传统货币通胀的手段。
- **长期增长潜力**：如果加密货币市场长期上涨，那么即使法币价值不增长，你的资产也可能因为持有更多的加密货币而变得更有价值。
- **避免频繁交易**：不需要频繁将加密货币兑换成法币，可以避免交易费用和税务上的复杂性。

### 需要注意的风险：
- **市场波动**：加密货币市场极其波动，币本位的策略可能在短期内面临较大的价值波动。
- **币种风险**：如果选择的基准币种表现不如预期，即使你的币种数量增加了，总价值也可能下降。
- **流动性问题**：在某些情况下，如果需要快速将加密货币转换为法币来应对紧急情况，可能会面临流动性风险。
