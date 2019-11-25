# [ActiveRecord关联的命名约定/规范](2019/11/includes-assocation)

相关文章 - [多对多的多表查询练习](/2019/hainan/join-query)

如果希望Account表关联上Member表，一个用户有多个钱包

建表的时候，只需在accounts表上加上`member_id`的字段，而members表不需要动

在**model/account.rb**中，写上 belongs_to `:member`

结果：通过`account.member.email`能直接获取钱包用户的邮箱

> [!NOTE|label:member和member_id区分命名的好处]
> 访问外键Member通过`acount.member`，获取外键ID通过`account.member_id`，从命名上区分**用途**

如果希望减少查询次数(如N+1查询)，在controller中`includes(:member)`

## has_many和has_one

如果希望通过Member反过来查询用户拥有哪些钱包，请看以下写法

<!-- tabs:start -->

#### ** accounts表 **

有个字段叫`member_id`，记得加上索引

#### ** belongs_to :member **

**model/account.rb** `belongs_to :member`

会自动生成以下完整版写法：

> belongs_to: :member, **class_name**: 'Member', **foreign_key**: :member_id

> 区分命名的好处：获取外键对象-`account.member`，获取外键ID-`account.member`

#### ** (可选)includes **

controller中：`@accounts = Account.includes(:member)`

!> 虽然不加includes也能访问外键对象，但是加上以后能减少查询次数避免N+1查询

#### ** has_many和has_one **

如果有需求要*查询用户拥有的所有钱包*

那么在 **model/member.rb** 中 `has_many :accounts`

使用：`member.accounts` (会返回一个<mark>数组</mark>)

> [!NOTE|label:has_one和has_many的区别]
> has_one使用单数形式，has_many使用复数形式且会返回一个**数组**

<!-- tabs:end -->

## 指定别的外键名，不遵守命名约定

Manager有多个Operation,每个Operation属于一个Manager，

但是Operation表的Manager外键不希望命名为manager_id，老板觉得可读性不行

那好吧，命名为operator_id如何？——不行，没有operators这个表，不要这样**误导性**命名

最后的命名方案: operator_member_id 或 operator_manager_id

原本 `belongs_to: :manager`, 会自动生成为：

> belongs_to: :manager, **class_name**: 'Manager', **foreign_key**: :manager_id

!> 因为没按约定，所以要告诉rails外键名是`operator_member_id`而不是`manager_id`了

不遵守rails命名约定带来的麻烦是，belongs_to和has_many/one**要指出外键名**

<!-- tabs:start -->

#### ** model/operations.rb **

**项目军规**是:每个外键必须建立起<mark>双向关联</mark>

> belongs_to :manager, **foreign_key**: `'operator_member_id'`

完整写法：

> belongs_to :manager, class_name: 'Manager', **foreign_key**: `'operator_member_id'`

#### ** (双向关联)model/manager.rb **

> has_many :general_operations, **foreign_key**: `'operator_member_id'`

#### ** Controller **

@operations = Operation.includes(:operator_member)

#### ** Views **

> operation.operator_member_id %>,<br>
> link_to operation.manager.try(:email) || '', managers_path %>

<!-- tabs:end -->

---

还有一种情况，有两个字段的外键指向相同一个表，如发送人，接收人

> belongs_to :sender_member, **class_name**: 'Member'
> belongs_to :receiver_member, **class_name**: 'Member'

写上这两句就能以`xxx.sender_member.email`访问发送者邮箱

\## has_xxx through:

医生有多个病人，通过第三个表 预约记录，那么医生model中has_many 病人, through: 预约记录

