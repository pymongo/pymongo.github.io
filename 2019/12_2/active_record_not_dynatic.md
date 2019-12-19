# [active_record的值并不是动态的](/2019/12_2/active_record_not_dynatic.md)

例如在第一行中 `account = Account.where(...).first`

当我修改了account的balance并且save!/update!了

再次取`account.balance`还是修改前的值

这是我写账户变动相关的单元测试时遇到的一个"坑"

ActiveRecord不会动态更新值的原因很简单，

因为值是存在数据库里的，不可能每次获取值都要执行一条SQL吧
