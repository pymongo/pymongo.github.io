# [bn alpha](/2025/06/bn_alpha.md)

以前看不上alpha 现在套利不好赚钱了放下我的偏见科学家也刷alpha了。我主要用的两个刷alpha的工具

- [我账号积分](https://alpha.dog/#alpha/one-i/0xd4b4372f1c7759f12c0e0b7e5cad2f5c833da66d)
- [我妈账号积分](https://alpha.dog/#alpha/one-i/0xee55c0ce850f150caa779fb274d52232e913795d)
- [我哥账号积分](https://alpha.dog/#alpha/one-i/0xEFCF391282f9ec52E20441D230614C8CBDEb652D)

我表弟地址: 0xE00b0C192108aA53028EFD07d7438E8FFdfb8dB6

之前用的工具 https://www.bn-alpha.site/0xd4b4372f1c7759f12c0e0b7e5cad2f5c833da66d
zkj/koge交易额算的偏少了 导致我多刷 换 alpha.dog 工具了

https://www.bn-alpha.site/0xee55c0ce850f150caa779fb274d52232e913795d

|||
|---|---|
|https://litangdingzhen.me|往期alpha合格人数和利润|
|https://dune.com/ethan714/bn-alpha-analysis|dune数据每天刷15分交易量人数(不含余额分)|
|https://www.bn-alpha.site|查钱包当天买入交易量和磨损|

dune数据可以用 https://tonvox.com/

类似的查分工具: https://blockai.pro/alpha-tool  https://alpha.dog/#alpha/address

25/06/02的空投已经要223积分了 日积分17的话 每天多1积分 等于15天多1

- https://alpha-cal.vercel.app alpha积分利润计算器
- https://alphapoint.fun 授权合约内存池发现币安钱包买入后 插一笔同区块卖出降低磨损|
- https://memego.ai/bnAlpha 类似的同区块工具 不过alphapoint的开源有机会fork源码去掉抽成
- pankeswap: 查询当前深度最好的LP决定刷哪个币
- bscscan: 区块浏览器

只有买入交易量计入积分 2**1=1积分 但只要交易量是 >2 <=4 得到 log2(4)=2 积分

所以只要比 2的n次方多一丢丢就能计入 n积分 例如2**13=8192 刷了8193买入交易量 等同于 13+1也就是log2(16384)的积分

交易所"锁仓"资金分配:
FDUSD 300 USDC 100 其余USDT理财

第二种减少频繁买卖的操作思路

```
因为少刷了，以我刷 5 笔为例，正常刷需要 10 笔，但按这种只需要刷 6 笔，次数少了理论上磨损就会小，但风险在于中间两个币来回捣鼓的时候会亏（当然也有可能赚）
U     →  ZKJ    第一笔
ZKJ →  B2      第二笔
B2   →  ZKJ    第三笔
ZKJ →  B2      第四笔
B2   →  ZKJ    第五笔
ZKJ →  U        卖回 U 不算交易量
```

我刷16384操作次数最少的路径

1. u->zkj 4098.3
2. zkj->koge
3. koge->zkj
4. zkj->koge 此时还剩 4096.97
5. koge->u 最后 4098.07

## 科学家发币操纵价格跟zkj组LP被堵死

例如发币 abc 组LP  abc/ZKJ  然后买卖abc中间操纵下价格 反正左手倒右手

https://x.com/degentalk_hk/status/1930630960543842339
