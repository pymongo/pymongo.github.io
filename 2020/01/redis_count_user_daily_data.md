# [redis存储时效性短的数据(如每日申诉次数)](/2020/01/redis_count_user_daily_data.md)

时效性短的数据，可存储于redis中减轻MySQL的负载

例如实现用户当日取消订单超过3次就限制交易的功能

MySQL实现很简单，BETWEEN AND：

ActiveRecord`where(state: 'cancel', updated_at: Date.today.beginning_of_day..Date.today.end_of_day)`

Redis:

```ruby
# redis给某个key的值+1方法(计数器)，有效期默认是1天
  # models/user.rb
  def redis_counter(key, time=86400)
    key = "#{key}_#{self.id}"
    # 获取redis中该key的剩余时间，过期或不存在都是返回-2
    expired_in = DataKeeper.ttl(key)
    # 如果key不存在，get(key)返回nil.to_i=>0，重新设置一个key
    # 如果key存在则继承之前的剩余时间
    DataKeeper.set(key, DataKeeper.get(key).to_i+1, expired_in>0 ? expired_in : time)
  end
# 获取计数器的值(也就是获取redis的值)
  # controller
  cancel_times = redis.get("cancel_times_#{user.id}") || 0
  if cancel_times > 3
```

类似用户当日取消订单超过3次就限制交易的业务逻辑还有

用户当天最多发起3次申诉，都建议使用redis存储
