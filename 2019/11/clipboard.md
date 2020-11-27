## 11.27

```ruby
account = Account.where("member_id = ? AND currency_id = ?", params[:member_id], params[:currency_id])
  .where("balance <> 0 OR locked <> 0").first
if account.blank?
  flash[:error] = "用户#{params[:member_id]}的#{Currency.find(params[:currency_id]).code}！"
  return
end
```

「重大改动」二级标题和三级标题的行距从2em改为1.5em，更有紧凑感


## mysql dump

> mysqldump -u user -p database_name table_name1[]...] > filename.sql

mysqldump -u root --password=daydayUP666888$$$ cadae id_card_approvals > s.sql

## select_tag添加class的方法

<%= f.select :status, options_for_select(%w(ok error)), {}, { class: 'form-control'} %>

## model_validate

```ruby
validates :interval_of_hook, :interval_of_sleep, numericality: {
  only_integer: true,
  greater_than_or_equal_to: 0,
  less_than_or_equal_to: 60,
  message: "间隔的单位是秒,只能取1到60之间"
}
validates :status, inclusion: {
  in: %w(ok error), message: "状态必须是ok或error"
}
```