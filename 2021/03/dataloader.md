# [dataloader解决重复查询](/2021/03/dataloader.md)

假设有两个相似的graphql查询接口，查询用户的关注数和粉丝数

```
schema {
    query: QueryRoot
}
type QueryRoot {
    user_follows(user_id: Int!): Int!
    user_followers(user_id: Int!): Int!
}
```

user_id是users表的主键，而graphql resolver的代码如下

```rust
// version 1.0
async fn user_follows(user_id: i32) -> i32 {
    let user = db::find_user_by_id(user_id).await;
    user.follows
}
async fn user_followers(user_id: i32) -> i32 {
    let user = db::find_user_by_id(user_id).await;
    user.followers
}
```

(当然这两个接口函数似乎并为一个会更好，合并成一个async_graphql::SimpleObject)

假设前端的graphql查询如下

```
query($user_id: Int!) {
    user_follows(user_id: $user_id)
    user_followers(user_id: $user_id)
}
```

如果一次grpahql请求内两次查询都是同一个user_id，那么第一个版本的resolver代码会重复查询user一次

## async_graphql缓存方案

```rust
// tide listener/unix_listener.rs
// server will accept connections when bind()
// handle_unix is referenced/usage in accept()
fn handle_unix<State: Clone + Send + Sync + 'static>(app: Server<State>, stream: UnixStream) {
    task::spawn(async move {
        let local_addr = unix_socket_addr_to_string(stream.local_addr());
        let peer_addr = unix_socket_addr_to_string(stream.peer_addr());

        let fut = async_h1::accept(stream, |mut req| async {
            req.set_local_addr(local_addr.as_ref());
            req.set_peer_addr(peer_addr.as_ref());
            app.respond(req).await
        });

        if let Err(error) = fut.await {
            log::error!("async-h1 error", { error: error.to_string() });
        }
    });
}

// tide server.rs
pub async fn respond<Req, Res>(&self, req: Req) -> http_types::Result<Res>
where
    Req: Into<http_types::Request>,
    Res: From<http_types::Response>,
{
    let req = req.into();
    let Self {
        router,
        state,
        middleware,
    } = self.clone();

    let method = req.method().to_owned();
    let Selection { endpoint, params } = router.route(&req.url().path(), method);
    let route_params = vec![params];
    let req = Request::new(state, req, route_params);

    let next = Next {
        endpoint,
        next_middleware: &middleware,
    };

    let res = next.run(req).await;
    let res: http_types::Response = res.into();
    Ok(res.into())
}
```

以我阅读tide源码的经验来看，Rust的所有web框架在server启动前都会创建一个app_data或app_context

用作"全局"变量，例如数据库连接池就会放在app_data中，app_data则要求里面的成员必须实现Clone

然后处理每次请求时，框架会将Arc的app_data clone一份交给api处理请求的函数

所以app_data默认都是不可变的，例如数据库连接池，例如配置文件结构体，如果少量成员需要可变则用Mutex或RefCell类似的方法实现可变性

<br/>

这就诞生了Rust是否需要static全局变量之争，有的人喜欢用lazy_static将例如密钥信息存入static中

而我喜欢在main函数序列化配置文件，并将其指针一层层往下传，这样就像crates模块管理树形结构那样整齐明了

也能进行静态分析和各种编译时检查，而用lazy_static/once_cell就失去了很多静态检查，运行时可能panic,所以有人说RefCell is lie to compiler

<br/>

既然app_data会"克隆"一份，所以一次请求的多个函数间共享缓存的解决方案是可以使用app_data

因为app_data每次请求都会克隆，克隆后的app_data用一些特殊可变数据结构作为缓存层，隔离开原版app_data，这样克隆后的app_data怎么乱改都不会影响原版app_data

但是async_graphql更像是所有请求通过不可变指针/引用的方式共用app_data，达到共享内存的效果，跟tide对Arc的app_data进行clone有点不同

以下是async_graphql关于app_data的部分源码

```rust
// schema.rs
let mut request = request;
let data = std::mem::take(&mut request.data);
let ctx_extension = ExtensionContext {
    schema_data: &self.env.data,
    query_data: &data,
};
// context.rs
pub fn data_opt<D: Any + Send + Sync>(&self) -> Option<&'a D> {
    self.query_env
        .ctx_data
        .0
        .get(&TypeId::of::<D>()) // fetch request's context data first
        .or_else(|| self.schema_env.data.0.get(&TypeId::of::<D>())) // if request's context data not contains, then fetch schema's data
        .and_then(|d| d.downcast_ref::<D>())
}
```

一次请求可能会调用多个resolver函数去执行，而resolver函数内部的data_opt方法会优先查询request.data再查询schema.data

但是request.data只提供getter方法，没法修改，所以只能用"全局"的schema.data也就是app_data内插入内部可变性的字段但是又能跟原版app_data隔离的缓存层

同事B称这个为service缓存层，但是没能实现。我作为非专业人士，试了下缓存的实现还是失败

## dataloader-rs

那就看看专业人士写的批量查询(解决N+1问题)+缓存，例如async_graphql内置的或dataloader-rs

首先我参考dataloader-rs的async_graphl example，用上了dataloader-rs后

查询同一个用户ID的user_follows和user_followers时，日志中只会出现一次数据库查询

```rust
pub struct UserBatcher {
    db: mongodb::Database,
}

#[async_trait::async_trait]
impl dataloader::BatchFn<u64, User> for UserBatcher {
    async fn load(&mut self, user_ids: &[u64]) -> HashMap<u64, User> {
        let mut ret = HashMap::new();
        for &user_id in user_ids {
            let user = find_user_by_id(key, &self.db).await.unwrap().unwrap();
            ret.insert(user_id, user);
        }
        ret
    }
}
```

但是同事A提醒这样写虽然多了缓存，但还是`N+1查询`，因为for循环id数组时对每个id进行1次查询

应该改成用select in这种数据库批量查询的语句

<br/>

我注意到dataloader-rs有缓存的现象，阅读源码后发现默认用HashMap做缓存层

而且没有「缓存过时或清理机制」，因为缓存在全局的app_data的`Arc<Mutex<HashMap>>`中

所以一旦用户ID1的查询结果被记入缓存，则以后的查询永远是缓存结果而不会更新

当然dataloader-rs公开了Cache Trait，可以自行用将redis封装成缓存层

## loader的错误传递

但是我跟同事争论最多的并不是缓存层问题，而是错误传递的问题

dataloader-rs所用load方法的返回值是`HashMap<K,V>`，没有考虑出错的情况

而async_graphql则是`Result<HashMap<K,V>>`

所以我认为dataloader-rs的V应该是`Result<Option<User>>`，load函数初始时根据输入的id数组

生成一个NoneError占位的HashMap(因为dataloader-rs从缓存中get失败会panic)，

正好mongodb的批量查询是通过cursor逐条返回数据

遇到一条数据则更新HashMap的值，所以我写下以下代码

```rust
#[async_trait]
impl BatchFn<u64, DbResult<User>> for UserLoader {
    async fn load(&mut self, user_ids: &[u64]) -> HashMap<u64, DbResult<User>> {
        let mut ret: HashMap<u64, DbResult<User>> = user_ids
            .iter()
            .map(|&user_id| (user_id, Err(crate::Error::DataLoaderNone)))
            .collect();
        // 丢失数据库查询的错误信息
        if let Ok(mut cursor) = self
            .db_igb
            .collection(Self::DB_COLLECTION_NAME)
            .find(doc! { "_id": { "$in": user_ids } }, None)
            .await
        {
            // 丢失了数据库cursor的错误信息
            while let Some(Ok(doc)) = cursor.next().await {
                // 丢失document序列化成struct的错误信息
                if let Ok(model) = from_document::<UserModel>(doc) {
                    let user: User = model.into();
                    ret.insert(user.id, Ok(user));
                }
            }
        }
        ret
    }
}
```

同事A很快指出我代码丢失了很多错误信息，我设想的状况是例如10个查询，能分别告诉id为1和3的错误信息，中途有一个查询失败也能继续。

但是我这样「批量查询中途某个失败也能继续」的思想是错的，批量查询就例如SQL的in,只是mongo能逐个返回，对于mysql之类的来说

要么出错不返回，要么全部正确，而且代码中document的所有权被消耗去序列化，后续再拿document去记录id是很麻烦而且带来额外的开销

dataloader-rs源码(也就500行)读完的我此时更相信async-graphql的实现了，不仅无缓存(无状态)而且还返回值带上错误处理

而且老大还说项目的并发访问量不大，没必要上缓存，所以我果断改用async_graphql::dataloader::Loader了

而且async-graphql自带cache_control，没必要再用dataloader-rs的缓存层

---

总结，dataloader并不是graphql专用的解决N+1查询的技术，其核心概念还是批量查询+缓存，适用性广，非graphql应用也可以用dataloader解决N+1查询
