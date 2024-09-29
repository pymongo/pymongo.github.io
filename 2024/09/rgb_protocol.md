# [BTC RGB](/2024/09/rgb_protocol.md)

```
https://github.com/bitcoin-core/btcdeb/blob/master/doc/tapscript-example.md
https://github.com/bitcoin-core/btcdeb/blob/master/doc/tapscript-example-with-tap.md
https://github.com/bitcoinops/taproot-workshop/blob/master/2.2-taptweak.ipynb
https://www.btcstudy.org/2022/06/13/part-2-bitcoin-p2tr-transaction-breakdown/#%E9%9A%94%E7%A6%BB%E8%A7%81%E8%AF%81-v0%EF%BC%9A%E5%8D%95%E7%AD%BE%E5%90%8D%E4%BA%A4%E6%98%93
https://www.btcstudy.org/2021/11/02/the-taproot-upgrade-explainer-from-Suredbits/
https://suredbits.com/category/taproot/
```

用 Bihelix-BTC地址(bc1q开头 隔离见证/taproot)
为什么大伙用wizz钱包居多而不是unisats
最多本地rgb20能自己弄个合约 本地转账测试
要不然就像bihelix 先不管版本 弄个闪电网络 走托管模式 要不然速度太慢
rgb -d .alice import test/rgb20-simplest.rgb 就是 这行命令
cargo install rgb-wallet --all-features --version 0.11.0-beta.8

花椒老师RGB课程
作业一: https://docs.qq.com/doc/DYkJXeVZuYlhEQ3Nh
```
RGB Quiz 1 学员 吴翱翔的提交
CBCDD DCCCD
1. C(D)
2. B
3. C
4. D
5. D(A)
6. D
7. C
8. C
9. C
10. D
答案: 1.D 2.B 3.C 4.D 5.A 6.D 7.C 8.C 9.C 10.D
```

## 为什么RGB节约交易数据空间
taproot之后存储成本增加，BTC全节点每年增加50G逐年变多，ORDI/染色币 上面有很多 未消费的 UXTO
降低每笔TX的数据大小成为BTC社区一种政治正确/原教旨主义
RGB的哲学就是我只需要交易对手方验证合法性 不需要全部数据上链尽可能简化

联盟链与zk隐私
联盟链好处是隐私，有些公链加了zk但是对具体资产的隐私不如RGB
RGB得到了bitfinex(USDT母公司)支持期望通过RGB在BTC发行USDT

## RGB特点
是一个配合UXTO链上和链下的框架 兼容闪电网络
采用先进zk算法 miblewhimble协议的bulletproofs技术 借鉴了blockstream的liquid侧链的保密资产技术(盲化的UTXO UTXO的混币器)
区块链只用作加密承诺层 椭圆曲线的同态属性来承诺一些链下数据 数据/历史由资产所有者维护
UXTO无法控制的一定可能出现DAG 交易双方只知道状态转移起点到终点路径的UXTO状态点，其他的灰色点完全不知，所以不容易做出区块浏览器
RGB合约比EVM合约安全，txdata数据大小几乎恒定

## RGB SDK项目
Bitlight Labs, bitmask.app
老谭深圳团队 Bihelix SDK已经集成到TP钱包，只要客户端(钱包)和dapp智能合约集成了SDK就可以进行RGB资产浏览器和交易，当然浏览器是中心化
https://help.tokenpocket.pro/cn/wallet-operation/create-wallet-tutorial/rgb
CKB项目创始人与btcstudy故事: https://x.com/shanshan521/status/1757418973271077364

## 构建invoice
https://youtu.be/RFMumrDOPyI?si=DhlsVjMzNzjm1R59&t=314

## RGB++
只需要知道收款人地址，不需要收款人提供invoice(UXTO) 尤其是闪电网络+RGB需要发送方收款人"同时在线"
