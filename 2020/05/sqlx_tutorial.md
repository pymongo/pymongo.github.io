# [sqlx教程](/2020/05/sqlx_tutorial.md)

sqlx不是一款ORM持久层框架，使用sqlx的好处是能充分利用MySQL/Postgres的SQL语句

相比之下Rust知名的ORM框架diesel就不支持`ORDER BY FIELD()`语句

如果您有一些SQL的基础，那么sqlx相比diesel而言上手难度更低，需要学习的内容也很少。

苦于sqlx官方文档都是以postgres为准，本文将以MySQL为例介绍sqlx。

先把MySQL的general_log、slow_log、error_log开启了方便Debug:

```
+------------------+--------------------------------+
| Variable_name    | Value                          |
+------------------+--------------------------------+
| general_log      | ON                             |
| general_log_file | /var/log/mysql_general_log.log |
+------------------+--------------------------------+
2 rows in set (0.07 sec)

mysql SHOW GLOBAL VARIABLES LIKE '%err%';
+---------------------+----------------------------------------+
| Variable_name       | Value                                  |
+---------------------+----------------------------------------+
| log_error           | /usr/local/mysql/data/mysqld.local.err |
| log_error_verbosity | 3                                      |
// ...

mysql SHOW GLOBAL VARIABLES LIKE '%slow%';
+---------------------------+-----------------------------+
| Variable_name             | Value                       |
+---------------------------+-----------------------------+
// ...
| slow_launch_time          | 2                           |
| slow_query_log            | ON                          |
| slow_query_log_file       | /var/log/mysql_slow_log.log |
+---------------------------+-----------------------------+
5 rows in set (0.00 sec)</pre>
```

## 创建数据库连接(池)

创建MySQL连接

```rust
use sqlx::{Connect, MySqlConnection};
MySqlConnection::connect(&db_url).await.unwrap()
```
r
创建MySQL连接池

```rust
use sqlx::mysql::MySqlPool;
MySqlPool::new(&db_url).await.unwrap()
// 或
MySqlPool::builder().max_size(16).build(&db_url).await.unwrap();
```

## 获取刚插入数据的id

不要用`ORDER BY ID DESC LIMIT 1`的方式去获取，不要以为表中最后一条数据就一定是当前连接/会话插入的数据。

要用MySQL的`LAST_INSERT_ID`这样的API去读取

```rust
async fn create_user(
    db_pool: &MySqlPool,
    username: &str,
) -> u32 {
    // BEGIN transaction
    let mut transaction = db_pool.begin().await.unwrap();
    sqlx::query(
        "INSERT INTO users (username) VALUES (?, ?, ?);",
    )
    .bind(currency_code)
    .bind(datetime)
    .bind(datetime)
    .execute(&mut transaction)
    .await
    .unwrap();
    // COMMIT transaction

    // 获取刚刚在事务处理中创建了user的MySqlConnection
    let mut db_conn = transaction.commit().await.unwrap();
    let last_insert_user_id = sqlx::query_as::<_, (u32,)>("SELECT LAST_INSERT_ID();")
        .fetch_one(&mut db_conn)
        .await
        .unwrap()
        .0;
    // 这里已经在函数的结尾处了，就懒得手动释放内存了
    // drop(db_conn);
    debug_assert_ne!(last_insert_user_id, 0);
    last_insert_user_id
}
```

## 记住两个API

实际上只需要记住两个sqlx的API就足以

- SELECT语句用`query_as+fetch_one/fetch_all`API
- 不返回数据的SQL(除了SELECT语句)用`query+execute`API

如果用到了query_as，需要`use sqlx::mysql::MySqlQueryAs;`

query_as API的类型参数是个tuple，不要依赖query!宏的编译时检查SQL语句，要用单元测试全覆盖所有SQL语句。

```rust
sqlx::query_as::<_, (u32)>(
        "SELECT id \
        FROM users \
        WHERE public_key = ? \
        LIMIT 1;",
    )
    .bind(public_key)
    .fetch_one(db_pool)
    .await
    .unwrap()
    .0;
```

如果想要db_connection对象则用db_pool.begin() API从连接池中获取一个(带事务的)连接

## SELECT 1保持连接

连接池的每个连接对象会时不时执行一个SELECT 1的查询语句用来保持连接或检查连接(类似websocket心跳包)

https://github.com/launchbadge/sqlx/issues/340

## sqlx的设计理念

没有用unsafe语句，没有多余的功能，而diesel相比之下多了数据库迁移/管理等功能

以我开发的经验，将业务代码和数据库迁移放一起是不合适的，数据迁移应该单独拎出来成一个独立的repo

例如用rails做数据库迁移管理，用sqlx写业务SQL查询就很不错了

而且sqlx在设计上也没有diesel那么复杂，需要读懂`Queryable+FromSql`才能读数据库，

`Insertable+ToSql`才能写数据库。而sqlx只需FromRow或者不用FromRow也能读取数据，

sqlx写数据库就更简单了，只要类型映射对，直接通过bind语句就够了
