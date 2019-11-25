# [多对多的多表查询练习](2019/11_1/join-query)

相关文章 - [ActiveRecord关联](/2019/11_2/includes-assocation)

## mysql样例数据库

[mysql官网的sample数据库employees](https://dev.mysql.com/doc/index-other.html)

一般都是用 source命令导入,不过教程要求要用 mysql -u root -p < employees.sql导入

!> 无论用何种方式建库, 都要保证数据库的编码是utf

employees并没有多对多的映射,不利于练习,不建议使用,建议使用[这个sample数据库](http://www.mysqltutorial.org/mysql-sample-database.aspx)

![表结构](http://www.mysqltutorial.org/wp-content/uploads/2009/12/MySQL-Sample-Database-Schema.png)

从图中或查询可知products和orders之间是多对多的关系

### 不建议使用这些样例数据库

好不容易找到个表名命名规范符合rails约定的样例数据库

可是字段名却是驼峰式命名，而且主键的字段名也不是id

倒不如自己构思出数据之间的逻辑用Faker或洗牌自动生成数据

## ActiveRecord外键

数据库实际字段名: to_account_id(INT)

model里面的写法:

<!-- tabs:start -->

#### ** 数据库字段名 **

> to_account_id -- (INT)外键=accounts表的ID

#### ** model中表间关联的写法 **

!> 注意:命名规范: 外键在数据库中有_id后缀而rails中不能写_id后缀

> belongs_to :to_account, class_name: 'Account'

#### ** 通过外键使用accounts表 **

> &lt;%= virtual_asset.to_account.currency.code %>

#### ** 多表关联下的遍历 **

遍历方法一:

> @virtual_assets.includes(:operator, :to_account).each

遍历方法二:

> @virtual_assets.each 

<!-- tabs:end -->

## 两个外键指向同一个表的

表1是邮箱名表,有两个字段: id, email

表2是邮件收发记录,有三个字段: from_id, to_id, text

需求: 如何筛选出 指定发件人 和 指定收件人 的邮件内容?

分析: 这是级联查询?必须要 内连接 邮件名表两次, 有alias区分发件人email和手机人email

技术细节: ActiveRecord的原生joins方法并不能给关联的表起别名, 需要自己写原生的SQL语句进行连接

```ruby
@email_records = EmailRecord
if params[:from_email].present?
  if params[:to_email].present?
    @email_records = @email_records
      .joins("INNER JOIN emails AS sender ON from_member_id = sender.id")
      .joins("INNER JOIN emails AS reciver ON to_member_id = reciver.id")
      .where('sender.email = ? AND reciver.email = ?', params[:from_email], params[:to_email])
```
