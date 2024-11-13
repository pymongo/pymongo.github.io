# [币安公告ACT套利](/2024/11/binance_announcement_act.md)

- https://x.com/cryptocishanjia/status/1855862289699840454
- https://x.com/seaify1/status/1856314163691434303
- https://x.com/seaify1/status/1856310410120704122

币安发公告下午要上ACT现货(晚上上了合约)，方程式新闻2s内就完成几万的买入，被人质疑是老鼠仓

由于币安有大量CDN所以爬虫轮询可行性不高，推测方程式有办法请求到无CDN缓存的公告API

或者第二种思路，我轮询币安现货充币列表API，发现多了ACT就买入，毕竟开盘前会先开现货充币

不过有时候充币列表API会比公告慢，有时候可能是API更快，二者要结合
