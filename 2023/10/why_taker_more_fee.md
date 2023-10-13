# [为何 taker 手续费更高](/2023/10/why_taker_more_fee.md)

(有几年没做数字货币交易了，好多概念都忘了，同时也出现很多新的术语)

## 现货市价
下单接口中市价单不能设定价格，以最优市场价(book_ticker 也就是 order_book 卖盘最高价和买盘最低价)下单，适合想要快速成交的场景(俗称吃单)

但无论是市价还是限价最终成交价都可能变化，下卖单遇到更高价格的买单，会成交卖出更多钱，下买单遇到更低价格的卖单，会成交用更低价格买入

### taker 更有利?
maker 指的是一次撮合成交中先下单的一方 taker 是后下单的一方

假设 orderbook 初始状态为空，先下价格为 8 的卖单，再下价格为 10 的买单，最终会按 maker 价格成交

听上去 taker 用更低价格买到了，但是 taker 手续费更高且要考虑市场冲击，而 maker 也是吃亏在先挂单先冻结很多余额，maker 通常是做市商

### only maker 只下单不撮合

如果不是高频的话建议做 maker(only maker 单)

## 期货=永续合约?
现货的杠杆交易也是有杠杆就有借钱爆仓强平，现货杠杆向平台借币会有利息和到期时间，需要做空做多实现套利

做空就预测btc会跌向平台借btc一个，卖出1000u，两天后btc跌到800再用800回购一个还给平台，最后自己赚 200u 扣除利息和手续费。但现货 10 倍杠杆一旦做空失败 btc 反而涨 10% 就会强制平仓爆仓清零

永续合约也是向平台借钱有利息？

一般常用就u本位永续合约，跟恒大的永续债类似没有到期时间，少量交易所有交割合约有到期时间的合约

## 撮合引擎有可能有下单价格限制
例如下单价格必须在市场价的正负10%左右，例如gate的现货没有价格限制，永续有市价正负50%价格限制

> order price 1 while mark price 26807.56 and deviation-rate limit 0.5


---

## 撮合引擎源码分析

所有撮合引擎都是先判断订单类型，有没有 only maker 然后看是不是冰山单。

如果是普通的限价单，判断能否在当前的 Orderbook 中成交(例如 buy 单先在内存中跟 ask_orders 撮合)，
最后部分成交或者不能成交也就还有剩余数量的单写入到 Orderbook 中

先看看 ruby 开源交易所(pixiu) peatio 的代码，后面再看新一点的 Rust 撮合 github.com/uinb/galois

```ruby
# app/api/api_v2/orders.rb:48
desc 'Create a Sell/Buy order.', scopes: %w(trade)
params do
    use :auth, :market, :order
end
post "/orders" do
    order = create_order params

# app/api/api_v2/helpers.rb
def create_order(attrs)
    order = build_order attrs
    Ordering.new(order).submit

# 提交到了 AMQPQueue
```

消费者在 app/models/worker/matching.rb, app/models/matching/engine.rb 关注下 submit 相关代码

从秘猿科技官网看到原来 peatio 捐献给某组织还在维护 <https://github.com/openware/peatio>

在 2023 版本的代码中撮合的代码在 app/trading/matching/order_book_manager.rb 感觉新版的代码元编程和抽象用的太多更难看懂还是看看老版代码

---

## 双花问题

双花问题通常发生在分布式系统中，双花问题（Double Spending）是指攻击者使用同一份数字资产（如加密货币）进行多次交易的问题，而不让网络意识到这种重复交易的存在。这是一种安全性问题，因为如果双花问题没有被有效解决，就会导致虚拟货币系统的信任和可靠性受到威胁。

## 余币宝
就是交易所的保本活期或定期理财产品，23 年美联储加息，u 的利息就 3% 不到，也就略微比余额宝多一丢丢，比起 ETH lido 5% 的活期利息低不少

```
Lido是一个以太坊（ETH）的理财项目，它提供了一种将ETH存入Lido协议并获得稳定利息的方式。Lido的主要目的是为ETH持有者提供流动性和参与权益证明（PoS）网络的机会。

以太坊正在进行由工作量证明（PoW）到权益证明（PoS）的转型，这意味着ETH持有者可以将自己的ETH质押在ETH 2.0的Beacon链上，以支持网络的安全性和共识机制。然而，质押ETH在ETH 2.0网络上是被锁定的，无法立即转售或用于其他目的。

Lido允许用户将他们的ETH存入Lido协议，然后Lido将其质押在ETH 2.0网络上，代表用户参与网络并获得相应的质押奖励。同时，Lido向用户发行的Lido Staked Ether（stETH）代币代表着质押的ETH份额，并可在二级市场上自由交易。此外，每天用户持有的stETH都会自动增长，因为Lido协议会将质押奖励通过stETH的增加方式分发给持有者，这就是所谓的稳定利息。
```
