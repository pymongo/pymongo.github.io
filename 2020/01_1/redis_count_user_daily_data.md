# [redis存储时效性短的数据(如每日申诉次数)](/2020/01_1/redis_count_user_daily_data.md)

时效性短的数据，可存储于redis中减轻MySQL的负载

例如实现用户当日取消订单超过3次就限制交易的功能

MySQL实现很简单，BETWEEN AND：

ActiveRecord`where(state: 'cancel', updated_at: Date.today.beginning_of_day..Date.today.end_of_day)`

Redis:

```ruby
# 计数器方法的定义(仅用于计数)
  # models/user.rb
  def redis_counter(key, time=86400)
    key = "#{key}_#{self.id}"
    # 获取redis中该key的剩余时间，过期或不存在都是返回-2
    expired_in = redis.ttl(key)
    if expired_in > 0
      redis.set(key, redis.get(key).to_i+1, expired_in)
    else
      redis.set(key, 1, time)
    end
  end
# 获取计数器的值(也就是获取redis的值)
  # controller
  cancel_times = redis.get("cancel_times_#{user.id}") || 0
  if cancel_times > 3
```

类似用户当日取消订单超过3次就限制交易的业务逻辑还有

用户当天最多发起3次申诉，都建议使用redis存储
