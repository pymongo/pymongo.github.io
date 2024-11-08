# [LP portfolio](/2024/10/portfolio.md)

## 从套利调仓成LP
自从9月底FTM来了一个几十万资金的[套利机器人](https://www.okx.com/zh-hans/web3/explorer/ftm/address/0x7cad24365ba97881b304531211fa790b4e5db00a)
，经常是一个区块14笔交易13笔交易全是他的，我之前的ftm-okx套利机器人价差机会全被他抢单了。
频繁跟币安之间几十万的资金周转 可能是币安VIP9 maker，也就币安跟WigoSwap没到覆盖手续费的价差就开始交易了且滑点拉到1%不怕被夹

连续几天都没开单成功，全是滑点过大revert，要么做MEV要么做LP赚他钱，由于一来一回手续费0.6%加上AMM每次swap必然有滑点假设是0.2%
，所以MEV夹他1%的滑点可能风险也很高，不如做LP赚他钱，于是我做maker算了做套利机器人的对手盘。

## stake LP token
[tx](https://ftmscan.com/tx/0xb09c784efdea1d3d4a2d0e5763f0d78d1770c958dbb9646c7278ff29905a24af)
看了智能合约源码_pid和账户地址作为key存储了质押的LP数量，
tx输入数据中看到axlUSDC/WFTM交易对的_pid=24。

在[wigoFarm智能合约](https://ftmscan.com/address/0xa1a938855735c0651a6cfe2e93a32a28a236d0e9#readContract)中，
调用userInfo函数输入24和地址，可以查询到我质押。但是这个reward返回值更像是积分points跟网页上可claim的wigo奖励不一样

## hummingbot
有些AMM做市策略的bot或者机枪池
- https://hummingbot.org/strategies/amm-arbitrage/
- https://dhedge.org/dashboard

## portfolio tracker/dashboard
当我有多个链多个protocol不同LP池子不同LP代码的时候，很容易忘记自己质押资金在哪个defi协议产品，估算资金净值就很难，尤其是fantom spooky这样可能uniswapv3二次开发的智能合约代码。

evm系流行的debank,或者revert.finance这样的portfolio工具产品就很好用了，甚至还有历史数据

pulsar.finance好处是API免费额度，solana还算准但sui不支持native USDC, sui可以用app.getnimbus.io，blockvision要钱

## debank
想起了我在公司笨方法bsc,ftm,metis等一个个去找api去对接...

## 估算并对冲AMM头寸
