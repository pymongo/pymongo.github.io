# [涉及钱的操作要加事务处理和线程锁](2019/11/active_record_with_lock.md)

ActiveRecord的lock老大说只是一个**数据库锁**,并不是**线程锁**

如 account.balance -= amount 要写成

<!-- tabs:start -->

#### ** with_lock写法 **

```ruby
Account.transition do
  account.with_lock do
    account.balance -= amount
    account.save!
  end
end
```

#### ** lock!写法 **

```ruby
Account.transition do
  account.lock!
  account.balance -= amount
  account.save!
end
```

<!-- tabs:end -->

加事务的目的是如果中途出错, 账户变动会回滚

加数据锁的目的是防止多个线程同时修改
