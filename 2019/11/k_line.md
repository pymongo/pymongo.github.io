# [怎么看懂k线图](/2019/11/k_line.md)

维基百科搜索`Candlestick Charts`可以找到相关词条

以[火币的币币交易](https://www.huobi.com/en-us/exchange/)为模板进行讲解

首先横轴上每个柱体(蜡烛)表示**时间上的最小单位**, 如火币默认每个蜡烛的默认时间单位15min

每个蜡烛蕴含了这个时间段的四个数据, 从上到下排序为: 最高价,开盘价/收盘价,最低价

如果开盘价大于收盘价, 蜡烛为红色, 反之为绿色

!> 蜡烛为绿色时, **开盘价**在蜡烛<mark>下方</mark>

<table>
<tr><th></th><th>上蜡芯</th><th>上烛身</th><th>下蜡芯</th><th>下蜡芯</th></tr>
<tr><td style="color:red">红色蜡烛</td><td>最高价</td><td style="color:red">收盘价</td><td>开盘价</td><td>最低价</td></tr>
<tr><td style="color:green">绿色蜡烛</td><td>最高价</td><td style="color:green">开盘价</td><td>收盘价</td><td>最低价</td></tr>
</table>

上烛芯与上烛身之间的间距称为 **上影线**

**术语**:

- MA=Moving Average

---

由于要接手公司某个k线图相关的项目，所以要临时补下k线图相关知识

vue.config.js::devServer.proxy

> [!NOTE|label:作用]
> 将 没匹配到静态文件的请求 代理到该字段指向的地方

```js
module.exports = {
  devServer: {
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true,
        pathRewrite: {
          '^/api': ''
        }
      },
    }
  }
}
```

在main.js中引入 vue-resource 就可以全局使用$http
