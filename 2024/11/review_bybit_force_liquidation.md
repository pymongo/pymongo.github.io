# [复盘bybit爆仓](/2024/11/review_bybit_force_liquidation.md)

复盘bybit爆仓原因
我bybit测试账号是花钱找非洲肯尼亚人KYC的，老板说万一交易所要求人脸识别怎么办，不敢放大资金，所以就冲200用于测试

策略写了2-3周资金均衡没写完
有个头寸单腿空仓下午爆拉，被爆仓强平了

分析日志发现我轮询tx状态，process状态的tx回滚了导致我bybit对冲形成敞口头寸

(上午刚发现bybit-bn之间DRIFT套利机会，下午bybit就爆仓亏损了)

```
哈哈其实是我策略代码bug了半夜panic停机了，早上起来看还有几百个DRIFT的对冲仓位，平仓就赚了60

看了一圈 solend/kamino 都不能借出 DRIFT, bybit 现货杠杆也没开 DRIFT, 确实没有渠道借 DRIFT 套利

我早上是手动在 @DriftProtocol 网页上开空200u 币安开多 没想到开仓前突然有砸盘所以亏钱了

刚刚看bybit下午发公告drfit资金费率调成币安一样，堵住了币安开多bybit开空每8小时赚2.5%多仓资费的套利漏洞
```
