# [泊松分布](/2023/10/poisson_distribution.md)

描述单位时间内随机事件发生的次数的概率分布, 概率质量函数 P(k)= ( e**-λ * λ**k ) / k!

https://zhuanlan.zhihu.com/p/538673358 例如这个知乎文章的例题服务器每小时有30次请求，某5分钟内没有请求的概率

首先进行单位换算: λ_per_hour=30, λ_per_5min=2.5

没有请求表示发生次数为零将 k=0,λ=2.5代入进公式就是 math.exp(-2.5)=0.0821

scipy 的泊松分布概率质量函数是 `scipy.stats.poisson.pmf(k, lambda)`

例题2 某5分钟内不超过4次请求的概率 for i in range(4): posisson(i, 2.5)

例题3-4就很简单跟例题1一样把lamda的单位换算下代入公式即可

## 概率分布函数=累加和(概率密度函数)
我觉得中文翻译的不算好，概率分布听上去很懵

Cumulative distribution function 英文有个 Cumulative 一下子就搞懂了原来是概率密度函数 Probability mass function 的累加和/积分

难怪 不超过4次请求概率是 Fx(4)=P(0)+P(1)+P(2)+P(3)+P(4) 
