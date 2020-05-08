[归档 - 吴翱翔的博客](/)

[我的简历](/redirect/resume.html)

原始博客站点：[pymongo.github.io](https://pymongo.github.io)
镜像1：[wuaoxiang.github.io](https://wuaoxiang.github.io)
镜像2：[aoxiangwu.github.io](https://aoxiangwu.github.io)

## 我在开源社区上的贡献(PR)

### actix/examples

actix/examples 是actix_web的样例代码仓库

- [PR#298](https://github.com/actix/examples/pull/298) 删掉了关闭服务器example中两个未使用的变量，避免内存浪费

### wildfirechat/android-chat

野火IM是一款仿微信的聊天软件，我参与了安卓端的开发

- [PR#330](https://github.com/wildfirechat/android-chat/pull/330) 将聊天消息RecyclerView仅用于UI预览下显示部分设为tools:text

### lukesampson/scoop

scoop是一款windows系统的包管理工具，类似mac的homebrew或Linux的apt-get

当时的scoop基本靠人工发现软件新版本，然后手动更新bucket文件，我参与更新了7zip/sqlite的版本

不过现在scoop通过爬虫脚本自动抓取软件的最新版本，基本不需要人工更新bucket文件了

- [pull#2945](https://github.com/lukesampson/scoop/pull/2945) 更新windows系统包管理器工具scoop中7zip的版本号

---

## Github老外常见英文缩写

公司没有code review，学习全靠开源社区(PR/issue/读源码)，

经过不断地学习我成功在actix项目组中贡献了自己的[PR](https://github.com/actix/examples/pull/298)😄

以下是github issue/PR中老外的comment中常见的英文单词缩写

- AKA: Also Known As
- FYI: For Your Information
- AFAICT: As Far As I Can Tell

## 高频英语单词

- retrieve: 恢复
- Boilerplate code: 样板代码
- middleware: 中间件
- Primitive type: 原始类型(例如Java的int等等)

## 常用的又没背下来的命令

- find ~ -iname '*.apk'
- lsof -i :8080
- fuser 80/tcp
- netstat -nlp | grep :80

## 名词缩写

我个人不喜欢变量命名中将单词缩写的习惯，不过有些缩写还是要记一下免得看不懂别人代码

- srv -> server
- conn -> connection

## 线程相关的英文单词

- Parallel or Consecutively(并发或连续，指的是rust单元测试test case的运行方式)


Here is an example to map mysql datetime type to rust.

[reference - diesel/examples/mysql](https://github.com/diesel-rs/diesel/blob/master/examples/mysql/all_about_inserts/src/lib.rs)

Cargo.toml:

```
[dependencies]
dotenv = "*"
diesel = { version = "*", features = ["mysql", "chrono"] }
chrono = { version = "*", features = ["serde"] }
```

mysql table schema:

```sql
CREATE TABLE IF NOT EXISTS orders(
    id SERIAL PRIMARY KEY,
    created_at DATETIME NOT NULL
)
```

```
mysql> desc orders;
+------------+---------------------+------+-----+---------+----------------+
| Field      | Type                | Null | Key | Default | Extra          |
+------------+---------------------+------+-----+---------+----------------+
| id         | bigint(20) unsigned | NO   | PRI | NULL    | auto_increment |
| created_at | datetime            | NO   |     | NULL    |                |
+------------+---------------------+------+-----+---------+----------------+
```

src/schema.rs:

```rust
table! {
    orders (id) {
        id -> Unsigned<Bigint>,
        created_at -> Datetime, // or Timestamp
    }
}
```

src/model.rs:

```rust
use crate::schema::orders;
use crate::schema::orders::dsl::orders as orders_dsl;
use diesel::{MysqlConnection, RunQueryDsl, QueryDsl, ExpressionMethods};

#[derive(Queryable, Debug)]
pub struct Order {
    pub id: u64,
    pub created_at: chrono::NaiveDateTime
}

#[derive(Insertable)]
#[table_name = "orders"]
pub struct NewOrder {
    pub created_at: chrono::NaiveDateTime
}

pub fn create_order(ref_db_connection: &MysqlConnection) {
    diesel::insert_into(orders::table)
        .values(&NewOrder{created_at: chrono::Local::now().naive_local()})
        .execute(ref_db_connection)
        .unwrap();
}

pub fn last_order(ref_db_connection: &MysqlConnection) -> Order {
    orders_dsl.order(orders::id.desc()).first(ref_db_connection).unwrap()
}
```

src/**main.rs**

```rust
#[macro_use]
extern crate diesel;
use diesel::{Connection, MysqlConnection};
mod model;
mod schema;

pub fn establish_connection() -> MysqlConnection {
    dotenv::dotenv().ok();

    let database_url = std::env::var("DATABASE_URL")
        .expect("DATABASE_URL must be set in .env file");
    MysqlConnection::establish(&database_url).unwrap()
}

fn main() {
    let db_conn = establish_connection();
    model::create_order(&db_conn);
    let order = model::last_order(&db_conn);
    println!("{:?}", order);
}
```

Example output:

```
Order { id: 2, created_at: 2020-05-06T21:54:25 }
```