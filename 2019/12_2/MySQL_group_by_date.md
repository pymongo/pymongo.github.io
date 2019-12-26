# [MySQL按日期分组](/2019/12_2/MySQL_group_by_date.md)

老板给出需求，要用图表显示**每日**注册用户数、每日交易量之类的

我马上联想到python::pandas的datarange分组，其实查阅资料发现ruby的日期遍历更简单

<!-- tabs:start -->

#### **ActiveRecord**

> ActiveRecord.group("date(created_at)")

#### **MySQL**

```sql
SELECT
  SUM(created_at),
  DATE(created_at) AS daily
FROM
  users
GROUP BY
  daily
```

#### **ruby daterange**

```ruby
@from.step(@to, step=1) do |date|
  day_data = Order.where('created_at between ? and ?',
                          date.beginning_of_day, date.end_of_day)
end
```

<!-- tabs:end -->

!["MySQL_group_by_date"](MySQL_group_by_date.png ':size=484x304')

<i class="fa fa-hashtag"></i>
相关链接

[rails group records by date](https://stackoverflow.com/questions/12657753/rails-group-records-by-dates-of-created-at)

[pands dataframe group by date](https://stackoverflow.com/questions/12657753/rails-group-records-by-dates-of-created-at ':disabled')

