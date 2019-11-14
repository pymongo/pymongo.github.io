# [Add Default Constraint](2019/11/add-defult-constraint)

需求: 今天做offices表的CRUD的练手时发现offices表的字段实在是太多了

各种 `Field 'addressLine1' doesn't have a default value`的错误

我在index页面上就只有三个字段，总不可能offices有多少个字段就加多少行表单吧

所以还是挨个给不需要的字段家默认值的约束吧

然而在搜索网络资料中Stackoverflow居然好多答案都是语法错误的

## Mysql添加默认约束

```sql
ALTER TABLE offices
ALTER territory SET DEFAULT 'China';
```

验证操作成功： desc offices 或 describe offices

## SQL知识，W3School比Stack好用

经过这次搜索体验，在数据库相关的搜索结果中，我会把stack的权重调低，W3School的权重调高

## f.submit_tag 用错方法

form_tag 表单适用submit_tag， 而form_for表单要用f.submit而不是 submit_tag或其他

## 通过dup方法复制行
