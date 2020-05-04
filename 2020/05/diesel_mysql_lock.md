# [diesel给mysql加锁](/2020/05/diesel_mysql_lock.md)

工程上要在用户金钱变动操作(UPDATE语句)中加上事务处理和数据库锁，Mysql提高了[两种加锁的方式](https://dev.mysql.com/doc/refman/5.6/en/innodb-locking-reads.html)

- 共享锁(S锁): 可读不可写  | SELECT ... LOCK IN SHARE MODE
- 排他锁(X锁): 不可读不可写 | SELECT ... FOR UPDATE

Rust的diesel ORM远没有ActiveRecord强大，我照着diesel的文档/issues写了段更新用户余额的代码

diesel和rails类似([参考rails的悲观锁](http://siwei.me/blog/posts/database-rails-lock?nsukey=hwZ6d1hUtuWeSiKH0ZW1JtcnyomKorOni5m03o6ewyXbr8o56crhlODMNqfZN9817u%2BUxcoSB5QmmLMMAS5NFsTKMXnUqGMg8jXOaPcIx%2FZfq3HP4NPo30rzysFb%2FkHvY0c7zhIx0e%2FWRQNQ0UlJrRVbblEOjOtRC6k0AgIiyn2N9i%2F3iobZtv%2BkkFj%2BUiYMsdB0dZem7D9iMLofIzOn0Q%3D%3D))

只提供了通过`for update`语句加锁的方式，也叫「悲观锁」

rails会将SQL语句输出，而diesel只有Postgres支持，所以只能开启MySQL的Log去确认是否加锁了。

## Mysql开启general_log

[参考Stack Overflow](https://stackoverflow.com/questions/303994/log-all-queries-in-mysql)

```
sudo touch /var/log/mysql_general_log.log
sudo chmod 333 /var/log/mysql_general_log.log

mysql> SET GLOBAL general_log = 'ON';
mysql> SET GLOBAL general_log_file = '/var/log/mysql_general_log.log';
```

Rust代码，完整代码请看[diesel PR#2381](https://github.com/diesel-rs/diesel/pull/2381)

```rust
fn update_user_balance_with_lock(
    ref_db_connection: &MysqlConnection,
    user_id: u32,
    new_balance: i32,
) {
    ref_db_connection.transaction::<_, diesel::result::Error, _>(|| {
        // Lock the user record to avoid modification by other threads
        users_dsl.find(user_id).for_update().execute(ref_db_connection)?;

        diesel::update(users_dsl.find(user_id))
          .set(users::account_balance.eq(new_balance))
          .execute(ref_db_connection)?;
        Ok(())
    }).unwrap();
}
```

这个函数对应的Mysql查询语句是

```
Query	BEGIN
Prepare	SELECT `users`.`id`, `users`.`account_balance` FROM `users` WHERE `users`.`id` = ? FOR UPDATE
Execute	SELECT `users`.`id`, `users`.`account_balance` FROM `users` WHERE `users`.`id` = 8 FOR UPDATE
Prepare	UPDATE `users` SET `account_balance` = ? WHERE `users`.`id` = ?
Execute	UPDATE `users` SET `account_balance` = 10 WHERE `users`.`id` = 8
Close stmt
Query	COMMIT
```

diesel似乎还提供了一个with_lock() API给数据库加锁，不过文档上没有例子

---

## diesel对我PR的回复

```
Can you please elaborate(阐述) why this needs a distinct example in the example directory,
instead of just improving the API documentation here,
especially as this example applies to multiple backends, but is only provided for one.
```

虽然diesel作者拒绝了我的PR，不过我不后悔，提PR的过程中学到了不少新知识。

挺欣赏diesel作者对项目代码质量的高要求，我水平太低过不了他的review

我的英语水平、技术水平还需要质变才能参与diesel的开发。
