# [diesel CRUD示例](/2020/11/diesel_crud.md)

以下是diesel CRUD的示例，[完整源码](https://github.com/pymongo/diesel_crud)

```rust
/*!
CREATE TABLE users (
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	email TEXT NOT NULL UNIQUE,
	created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
*/
mod schema {
    table! {
        users (id) {
            id -> Integer,
            email -> Text,
            created_at -> Timestamp,
        }
    }
}
mod models {
    use super::schema::users;
    #[derive(Queryable, Debug)]
    pub struct User {
        pub id: i32,
        pub email: String,
        pub created_at: chrono::NaiveDateTime,
    }

    #[derive(Insertable)]
    #[table_name = "users"]
    pub struct UserInsert {
        pub email: String,
    }
}
#[macro_use]
extern crate diesel;
use diesel::{
    result::Error as DieselError, sql_types::BigInt, sqlite::SqliteConnection, Connection,
    ExpressionMethods, QueryDsl, RunQueryDsl,
};
use models::{User, UserInsert};
use schema::users::dsl::{created_at, id, users};

fn create_user(conn: &SqliteConnection, new_user_form: UserInsert) -> Result<User, DieselError> {
    no_arg_sql_function!(last_insert_rowid, BigInt);
    diesel::insert_into(users)
        .values(&new_user_form)
        .execute(conn)?;
    let new_user_id: i64 = diesel::select(last_insert_rowid).first(conn)?;
    let last_insert_user: User = users.find(new_user_id as i32).first(conn)?;
    Ok(last_insert_user)
}

fn read_users(conn: &SqliteConnection) -> Result<Vec<User>, DieselError> {
    Ok(users.load::<User>(conn)?)
}

fn update_user_created_at(conn: &SqliteConnection, user_id: i32) -> Result<(), DieselError> {
    diesel::update(users.filter(id.eq(user_id)))
        .set(created_at.eq(chrono::Utc::now().naive_utc()))
        .execute(conn)?;
    Ok(())
}

fn delete_user_by_user_id(conn: &SqliteConnection, user_id: i32) -> Result<(), DieselError> {
    diesel::delete(users.find(user_id)).execute(conn)?;
    Ok(())
}

fn main() -> Result<(), DieselError> {
    let conn = SqliteConnection::establish("file:db.sqlite").unwrap();
    diesel::delete(users).execute(&conn)?;
    // CRUD - Create
    let test_user_email = format!(
        "test+{}@example.com",
        std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH).unwrap().as_secs()
    );
    let last_insert_user = create_user(&conn, UserInsert { email: test_user_email})?;
    // CRUD - Read
    dbg!(read_users(&conn)?);
    // CRUD - Update
    update_user_created_at(&conn, last_insert_user.id)?;
    dbg!(read_users(&conn)?);
    // CRUD - Delete
    delete_user_by_user_id(&conn, last_insert_user.id)?;
    Ok(())
}
```

看相关issue讨论才发现diesel提供了no_arg_sql_function!和sql_function!两个宏去binding数据库的API方法，

比直接执行原生SQL的`SELECT LAST_INSERT_ID()`会更方便简洁

## 我在Rust社区关于diesel的贡献

- [video of diesel Decimal and Datetime type](https://youtube.com/watch?v=yFRCsZs5eRU)
- [My answer on Retrieve datetime from mySQL database using Diesel](https://stackoverflow.com/questions/49412797/retrieve-datetime-from-mysql-database-using-diesel)
- [My tweet about diesel CRUD example](https://twitter.com/ospopen/status/1333311825589411840)

## Decimal类型的映射

diesel crate开bigdecimal feature即可，再按需决定是否开启bigdecimal的serde feature

## diesel_cli的排错

### Linux安装diesel_cli前所需库

根据[官方README](https://github.com/diesel-rs/diesel/blob/master/guide_drafts/backend_installation.md#user-content-debianubuntu)
linux在安装diesel_cli之前需要预先装好libsqlite之类的库

### diesel print-schema rails管理的数据库会报错

原则上`src/schema.rs`是让print-schema根据数据库中的表结构去自动生成的，简化人工操作

原因是rails用于记录migration的表没有primary key

通过`diesel print-schema --help`查看帮组文档得知，使用-o参数可以指定表明从而跳过rails的迁移记录表
