# [Vue页面跳转时携带参数](/2020/09/vue_router_params.md)

从列表页进入详情页，例如从财务记录列表进入记录详情，一般要求列表页携带相应记录的id

例如安卓是通过Intent实现页面跳转时传参，那么vue用的是this.$router

下面这行代码起到了跳转到router中定义的name的路由的同时携带了id的参数

`this.$router.push({name: 'record_detail', params: {id: id}})`

在router中record_detail部分可以加上`props: true`的属性也可以不加

然后在接口的页面要这么解析:

`this.$route.params.id`

注意接收方页面不要写错成: this.$router.params，否则会undefined

今天遇到this.$route写错成this.$router导致解析失败的问题，看了[论坛上这篇帖子](https://forum.vuejs.org/t/router-params-is-undefined/3783)
才终于解决了这个问题
