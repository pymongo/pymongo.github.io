# System Design

## 防重入/超卖问题(如何防止用户重复点击导致表单重复提交)

category: 分布式、防重入、幂等性(Idempotence)

### 为什么需要防重入

假如售票网站只有一张火车票，结果用户鼠标重复点击买到了10张票

又例如微博点赞系统、淘宝好评系统，不希望一个用户就能刷好多个好评

### 前端应对措施

用户点击按钮发送表单请求后，将表单按钮「禁用」掉Vue或安卓的按钮都用disable(属性)

等到网络请求(一般都是异步的)的response回调中将按钮恢复

以js的fetch API为例，调用fetch()的上一行禁用按钮，在`.then(response`时恢复

```js
button.disabled = true;
return new Promise((resolve, reject) => {
    fetch(url, {
        body: "user_id=1",
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
    }).then(response => {
        console.info(response)
        if (response.status !== 200) {
            console.error(`HTTP status_code(${response.status}) != 200`)
            reject(new Error(`HTTP status_code(${response.status}) != 200`))
        }
        response.json().then(data => {
            console.log(`== [on response]${url}`)
            console.info(data)
            button.disabled = false;
            resolve(data)
        })
    }).catch((e) => {
        console.error(e)
        reject(e)
    })
})
```

这样处理之后，每个client在同一时间只能发起一个请求

但是仅靠前端作防止重复提交的处理是不够的，防不了使用爬虫或其他HTTP客户端发起的请求

### 后端防重入应对

所谓幂等性，在编程领域指的是`对同一个系统，使用同样的条件，一次请求和重复的多次请求对系统资源的影响是一致的`

方法一：请求携带token参数

每一次操作生成一个唯一性的token，一个token在操作的每一个阶段只有一次执行权

以电商应用为例，用户购买商品可分为 订单表创建一条订单记录、商品的库存减少、锁定优惠券、支付 等等

例如用户下单后因余额不足而支付失败，用户请求的token就卡在了支付的阶段，再次发起请求时不会走前面的流程，只会从支付开始走

具体的代码实现可以使用状态机或状态转移图的编程范式

方法二：数据库，一张临时性的去重表，用户ID和订单ID字段是unique的，每次下单请求都往去重表写一次，支付/库存减少的操作就只看去重表的数据，不看请求的数据

方法三：共享变量/数据库的相关加锁，让相同的请求必须以严格的先后顺序逐个处理