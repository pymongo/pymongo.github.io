# [循环贷亏2SOL](/2025/11/kamino_multiple_lose.md)

为了尝试提高被套牢的SOL的收益，我在 kamino multiple 开了 2.4倍杠杆循环贷，结果存钱113SOL 过一会立马提示亏损-120$ 半小时后取钱剩余111 瞬间亏掉2S

原来是循环贷，需要抵押SOL借出u swap成SOL，资金量大的话swap滑点手续费很不利 deposit时SOL价格164 高价借u买入sol 爆仓价128

withdraw在半小时后SOL跌到162 SOL贱卖亏2的价差换回u还债

由于循环贷的swap金额很大 所以 抵押SOL借u加杠杆 一旦SOL价格没有+0.3%覆盖开平仓手续费 一定是亏的

教训了 为了贪利息加杠杆 借贷market两边都是稳定币例如 USDE/USDT 都在1011出现过脱锚爆仓，更别提 SOL/USDC 这样币价波动很大的 波动点就血亏

不过还好平仓够快，164开 162平 然后SOL马上跌到142了...

## 循环贷类似币本位做多

循环贷做多完全等同于交易所现货杠杆币本位做多，类似币本位合约;

二者在暴跌的时候都会亏掉本金的SOL，上涨时币本位合约平仓赚SOL，循环贷multiple看借贷平台了借来的SOL卖出更多的u可能结算更多u也可能将u的利润换成SOL

- 暴跌时 循环贷需要贱卖借u买来SOL还不够还债就需要卖掉本金的SOL还u
- 暴跌时 币本位合约保证金价值是SOL也在跌比u本位杠杆更大
- 这就是通过借贷平台实现 现货杠杆 做多做空的效果

- deposit: https://solscan.io/tx/oUsKbqj2mMeNnQCFiMd17XY2dxTChELyXq145zCwv8rt9VHSqfQJ5tFaweopLT3FFgo7PqSPBLFPgKKQxhhU1qh
- withdraw: https://solscan.io/tx/21EZ5aTLhFtFwa4oqYnNgJurTAFt3f9ayfPoBJCB2FJSaVzD5RE8SdwWhKT8CupXsYM1nd5hiDczyoKaBWGkVf9m
