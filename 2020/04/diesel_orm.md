# [diesel的CRUD教程(Rust-ORM)](/2020/04/diesel_orm.md)

注意：本文一开始是用MySQL，后面改用PostgreSQL

Rust用diesel库建立ORM映射，我很好奇如何建立DATE和DECIMAL类型的映射

## 初始化数据库

首先要添加dotenv和diesel这两个库的依赖

```
dotenv = "0.15.0"
diesel = { version = "1.4.4", features = ["mysql"] }
```

如果之前没安装过diesel_cli，还需要安装下

> cargo install diesel_cli

在.env文件中添加DATABASE_URL的配置项:

> DATABASE_URL=mysql://username:password@localhost/actix_first

运行diesel setup，会自动创建好所需的数据库

!> 注意diesel setup会将所有的数据库迁移都执行一遍

### ubuntu:postgres初始化

1. su - postgres
2. psql
3. CREATE USER username WITH PASSWORD 'password';
4. ALTER ROLE username WITH CREATEDB(or SUPERUSER); 

### mac:postgres初始化

mac10.14.6系统下brew安装的postgres12.2一直连不上，

于是只好使用Postgres.app了。嘿嘿，不用的时候把App关掉就好了，还能节约内存，不像MySQL一直在后台占用内存

卸载了brew的postgres之后要重启才能正常使用。[将psql添加到PATH的方法](https://postgresapp.com/documentation/cli-tools.html)

1. CREATE USER username WITH PASSWORD 'password';
2. ALTER ROLE username WITH CREATEDB(or SUPERUSER); 

### 添加数据库迁移文件

> diesel migration generate create_users

会生成两个sql文件，手写建表的sql后， diesel migration run/redo 进行迁移

## CRUD

以社交网站上的post(po文)为模型，练习下diesel对表进行CRUD的操作。

看了官方文档和YouTube一些老外的教程，还是没做出来，最后感谢[台湾IT邦上的这篇文章！](https://ithelp.ithome.com.tw/articles/10205151)
让我实现了CRUD的代码。

### Create

<!-- tabs:start -->

#### ** main.rs **

```rust
#[macro_use]
extern crate diesel; // 记得要加macro_use，而且macro_use必须放在main.rs

mod diesel_helper;
mod models;
mod schema;

fn main() {
  let db_connection = diesel_helper::establish_connection();
  models::post::create_post(&db_connection, "author1", "title1", "body1");
}
```

#### ** diesel_helper **

```rust
extern crate dotenv;

use diesel::pg::PgConnection;
use diesel::prelude::*;
use dotenv::dotenv;

pub fn establish_connection() -> PgConnection {
  dotenv().ok();

  let database_url = std::env::var("DATABASE_URL")
    .expect("DATABASE_URL must be set in .env file");
  PgConnection::establish(&database_url)
    .expect(&format!("Error connecting to {}", database_url))
}
```

#### ** models/post.rs **

```rust
// https://ithelp.ithome.com.tw/articles/10205151
// Insertable 產生的程式碼會使用到，所以必須要引入
use super::super::schema::posts;
use diesel::pg::PgConnection;
use diesel::prelude::*;

#[derive(Queryable)]
pub struct Post {
  pub id: i32,
  pub author: String,
  pub title: String,
  pub body: String,
}

// 新增Post用的struct，唯一的差別是不需要「id」
#[derive(Insertable)]
// 要指定表的名称为posts，不然会类似rails把NewPost看做表名new_posts
#[table_name = "posts"]
pub struct NewPost<'a> {
  // The 'a reads ‘the lifetime a’. Technically, every reference has some lifetime associated with it
  pub author: &'a str,
  pub title: &'a str,
  pub body: &'a str,
}

pub fn create_post(conn: &PgConnection, author: &str, title: &str, body: &str) {
  let new_post = NewPost { author, title, body };

  // 指明要新增的表與新的值
  diesel::insert_into(posts::table)
    .values(&new_post)
    .execute(conn)
    .expect("Create Post Failed");
}
```

<!-- tabs:end -->
