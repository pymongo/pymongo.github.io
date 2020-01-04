# [ActiveRecord关联的命名约定/规范](/2019/11_2/active_record_association.md)

¶ [belongs_to - apidock](https://apidock.com/rails/ActiveRecord/Associations/ClassMethods/belongs_to)

如果希望Account表关联上Member表，一个用户有多个钱包，建表的时候，

- 在数据库的accounts表上加上`user_id`的字段，
- 在**model/account.rb**中，写上 belongs_to `:user`

会通过belongs_to类宏自动生成以下<var class="mark">完整版</var>代码：

> **belongs_to**: :user, <var class="mark">class_name</var>: 'User', <var class="mark">foreign_key</var>: :member_id, <var class="mark">primary_key</var>: :id

单向关联的好处：通过`account.user.email`能获取钱包用户的邮箱，代码简洁可读性强

> [!NOTE|label:member和member_id区分命名的好处]
> 访问外键Member通过`account.user`，获取外键ID通过`account.user_id`，从命名上区分**用途**

如果在`models/user.rb`中加上`has_many: accounts`

就能反过来通过`user.accounts`查询用户拥有的钱包，account和user建立起<var class="mark">双向关联</var>，

## 遍历中用了关联会N+1查询

```ruby
user.accounts.map { |account|
  {
    names: account.name,
    currencies: account.currency.name
  }
}
```

上诉代码如果没有currency这行，遍历时只会查询一次Account表的内容

但是跨表查currency时会对Currency表进行`N+1查询`

解决方案：先建立所需**关联**，通过**includes(:currency)**干掉`N+1查询`

正确地**建立关联+includes**能将N个SQL转化为`SELECT * FROM xxx WHER id IN [...]`

---

<i class="fa fa-hashtag"></i>
**has_many和has_one**

如果是一对一的关联，用has_one；否则用has_many

> [!NOTE|label:has_one和has_many的区别]
> has_one使用单数形式，has_many使用复数形式且会返回一个**数组**

## 关联同一个表两次

例如邮件记录表有俩字段sender_id和receiver_id

需要区分两个关联的名称，所以可以写成

belongs_to :sender, class_name: 'User'

## 指定别的外键名

Manager有多个Operation,每个Operation属于一个Manager，

但是Operation表的Manager外键不希望命名为manager_id，老板觉得可读性不行

那好吧，命名为operator_id如何？——不行，没有operators这个表，不要这样**误导性**命名

最后的命名方案: operator_member_id 或 operator_manager_id

!> 因为没按约定，所以要告诉rails外键名是`operator_member_id`而不是`manager_id`了

不遵守rails命名约定带来的麻烦是，belongs_to和has_many/one**要指出外键名**

> belongs_to :manager, **foreign_key**: `'operator_member_id'`

完整写法：

> belongs_to :manager, class_name: 'Manager', **foreign_key**: `'operator_member_id'`, `primary_key`: :id

---

## 多个外键关联同一个表

还有一种情况，有两个字段的外键指向相同一个表，如发送人，接收人

> belongs_to :sender, **class_name**: 'User'
> belongs_to :receiver, **class_name**: 'User'

写上这两句就能以`xxx.sender_member.name`访问发件人的姓名

[includes同一个表两次的解决方案(不完美)](/2019/12_2/includes_same_table_twice.md)

---

## [不通过主键(id)进行关联](/2019/12_2/association_without_primary_key.md)

---

<i class="fa fa-hashtag"></i>
has_many through:

医生有多个病人，通过第三个表 预约记录，那么医生model中has_many 病人, through: 预约记录

---

<i class="fa fa-hashtag"></i>
多态关联

**相关文章**

- [不通过主键(id)进行关联](/2019/12_2/association_without_primary_key.md)

- [includes同一个表两次的解决方案(不完美)](/2019/12_2/includes_same_table_twice.md)
