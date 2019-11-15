# [涉及钱的操作要加事务处理和线程锁](2019/11/data-lock)

如 account.balance += amout 要写成

```ruby
Account.transation do
  account.with_lock do
    account.balance -= amount
    account.locked  += amount
    account.save!
  end
end
```

account.with_lock可以换成lock! (本次项目的规范)

```ruby
Account.transation do
  account.lock!
  account.balance -= amount
  account.locked  += amount
  account.save!
end
```

加事务的目的是如果中途出错, 账户变动会回滚

加数据锁的目的是防止多个线程同时修改

## 导入csv批量修改冻结金额时一定要先验证

遍历csv时一定不要把金额变动写进数据库

把通过逻辑验证的数据存到数组中

如果`valided_arr.length == csv.length`则把通过的数据挨个写入数据库
