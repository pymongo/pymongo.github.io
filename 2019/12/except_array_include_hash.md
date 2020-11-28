# [except数组内包含特定哈希](/2019/12/except_array_include_hash.md)

业务需求：我的订单列表的单元测试

一个用户可能有多个订单，测试我的订单接口前先在orders表创建一行测试订单数据记录

我把测试数据的订单号设置为1888年开头的，确保了这条订单编号在接口返回的订单数组里是惟一的，

期待值通过**双重**`include`判断接口返回的json数组里包含这个订单

```ruby
expect(response_body["data"])
  .to include(include @except_output)
```

<i class="fa fa-hashtag"></i>
参考链接

- [https://stackoverflow.com/questions/52000714/rspec-check-if-array-contains-element-with-specified-id](https://stackoverflow.com/questions/52000714/rspec-check-if-array-contains-element-with-specified-id)
- [https://stackoverflow.com/questions/23815944/rspec-match-array-of-hashes](https://stackoverflow.com/questions/23815944/rspec-match-array-of-hashes)