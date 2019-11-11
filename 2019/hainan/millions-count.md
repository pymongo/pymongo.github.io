# [提高百万行记录count的速度](2019/hainan/millions-count.md)

## 百万级的数据count很慢

能不能不要精确值，用估算值去估算总行数

## explain

explain 前缀能分析后面的查询语句需要关联几个表，估算查询总行数等等

能否取出explain的返回结果中的row字段？可行性不高

本身这个语句就是用来排查性能问题的，不可能用于返回字符串结果

## 根据information_schema查估算行数

> select table_rows from information_schema.tables where table_name = 'orders' limit 1;

## rails中的写法

!> 不建议在模板文件中写数据操作

```ruby
<%= ActiveRecord::Base.connection.select_all("\
  SELECT table_rows \
  FROM information_schema.tables \
  WHERE table_name = '#{Order.table_name}' \
  LIMIT 1;").rows[0][0]
%>
```

## ruby::Benchmark 中的测试结果

ruby的Benchmark类可以测量语句的运行时间

### 新版查询语句的性能

```ruby
irb(main):080:0> Benchmark.measure {ActiveRecord::Base.connection.select_all("select table_rows from information_schema.tables where table_name = '#{Order.table_name}' limit 1;").rows[0][0]}
=> #<Benchmark::Tms:0x00007fbf56af41b0 @label="", @real=0.017163999960757792, @cstime=0.0, @cutime=0.0, @stime=0.00687799999999994, @utime=0.0012210000000001386, @total=0.008099000000000078>
```

### 旧版查询语句的性能

```ruby
irb(main):082:0> Benchmark.measure{Order.count}.real
=> 0.7543270000023767
```

## Mysql中新旧查询语句性能对比

```
+----------+------------+---------------------------------------------------------------------------------------------------+
| Query_ID | Duration   | Query                                                                                             |
+----------+------------+---------------------------------------------------------------------------------------------------+
|       25 | 0.00661400 | select sql_no_cache table_rows from information_schema.tables where table_name = 'orders' limit 1 |
|       26 | 0.91818300 | select sql_no_cache count(*) from orders                                                          |
+----------+------------+---------------------------------------------------------------------------------------------------+
```

## 为什么不要这么做

用户希望添加订单筛选条件后，能动态更新订单总数

不要在模板文件里面写数据处理或操作，这在Django中会直接报错
