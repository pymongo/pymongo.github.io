# [MySQL按日期分组](/2019/12_2/MySQL_group_by_date.md)

<!-- tabs:start -->

#### **ActiveRecord**

> ActiveRecord.group("date(created_at)")

#### **MySQL**

> SELECT SUM(foo), DATE(mydate) DateOnly FROM a_table GROUP BY DateOnly;

#### **ruby daterange**

```ruby
@from.step(@to, step=1) do |date|
  day_data = Order.where('created_at between ? and ?',
                          date.beginning_of_day, date.end_of_day)
end
```

<!-- tabs:end -->

!["MySQL_group_by_date"](MySQL_group_by_date.png ':size=484x304')

<i class="fa fa-hashtag mytitle"></i>
相关链接

[rails group records by date](https://stackoverflow.com/questions/12657753/rails-group-records-by-dates-of-created-at)

[pands dataframe group by date](https://stackoverflow.com/questions/12657753/rails-group-records-by-dates-of-created-at)

