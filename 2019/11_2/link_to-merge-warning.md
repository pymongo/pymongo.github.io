# [link_to merge参数时报错DEPRECATION](2019/11_2/link_to-merge-warning)

情景: a和b表是一对多的关系, 希望点击a表的id能跳到b表的查询条件 a_id=id

想当然的用和国际化切换语言一样的套路, 

> &lt;%= link_to lang[:name], params.merge(lang: lang[:code]) %>

当时看StackoverFlow大佬说这样写其实不好, 今天总算遇到错误了

```
DEPRECATION WARNING: Calling URL helpers with string keys controller, action is deprecated. Use symbols instead.
```

## 解决办法

```ruby
details_path(params.merge(operation_id: operation.id))
# 改为
details_path(operation_id: operation.id)
```

?> 最好的解决方案

hash.slice类似String的substring，避免了不必要的数据被暴露

> details_path(params.**slice**(`:operation_id`))
