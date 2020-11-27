# [account.first](/2019/11/account_first.md)

## where之后想取数据要加first

where之后明明只有一个Account实例,为什么去不到.balance

!> 错误写法: Account.where("member_id = ? AND currency_id = ?", id, $dsct).first.balance

```ruby
Member.all[0].class.name # Member

Member.all.class.name #ActiveRecord::Relation

Member.where("id = 19").class.name #ActiveRecord::Relation

Member.where("id = 19").first.class.name # Member
```

当对象为ActiveRecord时是无法读取各项值的,可以用.inspect大致看看
