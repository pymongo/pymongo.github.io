# [算法 - 等比级数](/2020/04/geometric_series.md)

dota游戏faceless void英雄的技能是攻击时24%的概率发动一次替身攻击(替身像日漫jojo的奇妙冒险)，

有趣的是，替身攻击时也有24%的概率召唤一个替身进行攻击(套娃)，参考[reddit上这个视频](https://www.reddit.com/r/DotA2/comments/9z4ntu/voids_omnislash_720/)

问题来了，这个技能能给普通攻击带来多少「数学期望」？

<i class="fa fa-hashtag"></i>
数学建模

以25%的概率造成200%的暴击伤害为例，数学期望为0.25*2+0.75=1.25

假设替身攻击最多两重：期望为0.24+0.24*0.24

有人问，第一个替身触发第二个替身的攻击，加起来不应该是3倍伤害吗？所以是0.24*1+0.24*0.24*2

其实第二次攻击只能算第一次的「增量」，也就是在0.24*1的基础上「额外多了一下」

所以说到底这还是一个无穷的等比数列，假设公比为q，首项为q

<!-- $S_{n^2}$: 下标是n^2 -->

<code>$ S_n = q + q^2 + \ldots + q^n $</code>

以我奥林匹克数学竞赛省赛二等奖的经验，S_n-1的左右乘以一个q，实现移项后「错位相减」

<code>$ qS_{n-1} = q^2 + \ldots + q^n $</code>

然后从$S_n - S_{n-1}$ 到 $S_2 - S_1$逐项相加

<code>
$\begin{aligned}
 Sn-qS_{n-1} = q \\
 \ldots \\
 S_2 - qS_1 = 0
\end{aligned}$
</code>

好吧发现圆不了，偷看下[维基百科的推导过程](https://upupming.site/docsify-katex/docs/#/supported)

$a + ar + a r^2 + a r^3 + \cdots + a r^{n-1} = \sum_{k=0}^{n-1} ar^k= a \left(\frac{1-r^{n}}{1-r}\right),$

<code>
$\begin{aligned}
s &= a + ar + ar^2 + ar^3 + \cdots + ar^{n-1}, \\
rs &=  \qquad  ar + ar^2 + ar^3  + \cdots  + ar^{n-1}+ ar^{n},  \\
s - rs &= a-ar^{n},  \\
s(1-r) &= a(1-r^{n}), \\
s &= a \left(\frac{1-r^{n}}{1-r}\right) \quad \text{(if } r \neq 1 \text{)}.
\end{aligned}$
</code>

好吧，发现我的大体思路是对的，只不过错位相减的被减项是$qS_n$而不是$qS_{n-1}$

现在可以解答文章开始时提出的问题，

替身攻击技能的期望是： $0.24 \times \frac{1}{1-0.24} \approx 0.31$

---

扩展阅读：[推导1^2+2^+...+n^2的部分和](https://brilliant.org/wiki/sum-of-n-n2-or-n3/)
