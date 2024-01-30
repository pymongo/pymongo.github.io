# [中国期货量读书笔记](/2024/01/chinese_futures_quantitative_notes.md)

在金融领域，尤其是在期货市场中，连续合约（Continuous Contract）指的是一种为了便于长期分析和交易而创造的合成合约。由于期货合约是有固定到期日的，当一个合约到期后，交易者需要转移到下一个交易月份的合约，这会造成价格、成交量等数据的不连续。为了解决这个问题，连续合约通过将历史上相继到期的合约数据“拼接”起来，形成一条可以追溯多年的连续价格走势线。

连续合约也可以理解成某商品最近成交量最大的合约，也可以理解成当周/当前周期的交割合约

所谓指数合约,指的是该品种上市的所有合约的加权合约(类似上证指数是市场几个蓝筹股的加权平均)。因此,实际上并不存在指数合约这
交易标的。之所以使用指数合约,是因为商品策略一般是隔夜策略,而连续合约在换月上会有较大跳空,回测
时候不准确

24-01-29读到1-2章 商品趋势策略(CTA)

## 夏普率

常数: 无风险(必定保本)下年化收益，一般取[美国10年国债年化收益](https://www.investing.com/rates-bonds/u.s.-10-year-bond-yield)

美国国债利息又是跟 [美联储利息相关 Federal Funds Rate](https://www.investing.com/economic-calendar/interest-rate-decision-168)

```python
def calculate_sharpe_ratio(returns, risk_free_rate):
    # Calculate the mean and standard deviation of returns
    mean_return = np.mean(returns)
    std_dev = np.std(returns)

    # Calculate Sharpe Ratio
    sharpe_ratio = (mean_return - risk_free_rate) / std_dev

    return sharpe_ratio

# Example monthly returns (percentage)
monthly_returns = [0.02, 0.03, -0.01, 0.015, 0.01, -0.02, 0.025, 0.03, -0.015, 0.02, 0.015, 0.01]

# Risk-free rate (2024-01 美国国债利息 4%)
risk_free_rate = 0.04

# Calculate Sharpe Ratio
sharpe_ratio = calculate_sharpe_ratio(monthly_returns, risk_free_rate)
```

夏普比率越高，说明单位风险所获得的收益越多

24-01-29读到 1.2.3

## 术语解释

- 漂亮50: NIFTY 50 指数
- 一九行情: 10%的在涨其余再跌，二八行情同理20%在涨
- MAR比率: 年回报与最大回撤的比值
