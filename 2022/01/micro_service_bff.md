# [微服务 BFF 数据聚合](2022/01/micro_service_bff.md)

[请教后端同学这种写接口的方式对不对？](https://v2ex.com/t/828191?p=2)

看到这帖子说后端接口因为微服务/DDD 之类的设计拆分成更细粒度的数据，例如订单状态、订单信息分开两个接口，以前是一个接口

网关和业务中台之间加入了一层 BFF(Backend For Frontend) 将三个接口聚合成一个

BFF 层后端做前端做也行，或者用 graphql 也有类似的效果

参考: https://www.cnblogs.com/edisonchou/p/talk_about_what_is_bff_in_microservices.html
