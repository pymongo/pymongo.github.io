# [返回CSV更友好的nil如果对象不存在](/2019/11/try_return_nil.md)

常用的判断对象/属性存在的方法：

member.try(:email), member.email?, member.email.present?

推荐吧params[:member_id].present?写成`params.key? :member_id`

`member.try(:email)`返回的是空字符串，对csv不友好

希望记入csv的是NULL而不是""，则写为：

> member.try(:email).`presence`

[参考链接(StackOverflow)](https://stackoverflow.com/questions/15419285/converting-an-empty-string-to-nil-in-place)