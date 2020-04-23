# [diesel映射datetime、decimal类型](/2020/04/diesel_datetime_decimal.md)

我在YouTube上[录了一个视频](https://www.youtube.com/watch?v=yFRCsZs5eRU)
演示diesel操作datetime和decimal类型

源代码在youtube的视频信息上，所以本文尽量不会贴源代码，而是以「方法论」为重点去讲解学习的过程

以下是「复盘」解决datetime/decimal类型映射的过程

---

<i class="fa fa-hashtag"></i>
diesel print-schema

如果尝试用diesel扫描rails的数据库会报错，因为rails有个记录migration的表是「没有主键」的

当时我遇到这个问题卡住很久了，上司过来打了一句 diesel print-schema --help就解决了(加上-o参数指定表名)

于是schema.rs没问题了，类型映射为：

```
price -> Decimal,
created_at -> Datetime,
```

---

<i class="fa fa-hashtag"></i>
diesel print-schema

官方文档没有讲解datetime和decimal类型的映射，

我想到的方法是去stackoverflow上面去搜索，结果有相关的问题但是没有人回答

于是有两个方法，一是去看issue，二是去看源码

个人感觉发issue的水平良莠不齐，可读性也不高，翻找半天勉强找到一些有用的代码片段

将Cargo.toml的chrono/bigdecimal加上了`features = ["serde"]`

重大意义是，datetime/bigdecimal类型可以被序列化/反序列化啦

我按mysql+diesel+datetime的关键词搜索一翻无果后，尝试看看报错:

> ... not impl Trait from_sql and to_sql ...

然后我就在diesel源码里面搜索 from_sql和to_sql

结果发现[mysql/types/numeric.rs](https://github.com/diesel-rs/diesel/blob/master/diesel/src/mysql/types/numeric.rs)
里面含有实现bigdecimal类型from_sql和to_sql方法的代码

所以启用下diesel的相应feature即可

于是很容易地就写完了查表的代码

```rust
use crate::schema::orders;
use crate::schema::orders::dsl::orders as orders_dsl

#[derive(Queryable, Serialize, Deserialize, Debug)]
pub struct Order {
  pub price: BigDecimal,
  pub created_at: chrono::NaiveDateTime,
}

pub fn find_by_market_id(conn: &MysqlConnection) -> Vec<Order> {
  orders_dsl.limit(5)
    .load::<Order>(conn)
    .unwrap()
}
```
