# [k-line-vue](2019/11/k-line-vue)

## 股票k线图知识

维基百科搜索`Candlestick Charts`可以找到相关词条

以[火币的币币交易](https://www.huobi.com/en-us/exchange/)为模板进行讲解

首先横轴上每个柱体(蜡烛)表示**时间上的最小单位**, 如火币默认每个蜡烛的默认时间单位15min

每个蜡烛蕴含了这个时间段的四个数据: 开盘价,收盘价,最高价,最低价

如果开盘价大于收盘价, 蜡烛为红色(亚洲习惯)

## vue一些配置

### vue.config.js::devServer.proxy

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

### volume

任务:

eleme-ui 的 datetime picker