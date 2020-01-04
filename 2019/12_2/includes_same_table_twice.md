# [includes同一个表两次的解决方案(不完美)](/2019/12_2/includes_same_table_twice.md)

<i class="fa fa-hashtag"></i>
相关文章

[ActiveRecord关联的命名约定/规范](/2019/11_2/active_record_association.md)

<i class="fa fa-hashtag"></i>
问题重现

`members`表有`email`字段和`id`字段

`transfers`表(邮件记录)只有`from_member_id`和`to_member_id`字段与`members`表关联

> [!TIP|label:按邮箱查询]
> 如何按`发件人邮箱`和`收件人邮箱`查询邮件记录表

<!-- tabs:start -->

#### **新版写法**

```ruby
before_action only: [:index, :download_csv] do
  @transfers = InternalTransfer.includes(:from_member, :to_member, :currency)
  if params[:from_email].present? && params[:to_email].present?
    @transfers = @transfers.where("members.email = ?", params[:from_email]).references(:from_member)
    if params[:to_email].present?
      filter_by_to_email = @transfers.select { |x| x.to_member.email == params[:to_email] }
      @transfers = @transfers.where(id: filter_by_ato_email.map(&:id))
    end
  else
    @transfers = @transfers.where("members.email = ?", params[:to_email]).references(:to_member) if params[:to_email].present?
  end
end
```

#### **旧版写法(joins)**

```ruby
private
def search_by_params
  @transfers = InternalTransfer
  if params[:from_email].present?
    if params[:to_email].present?
      @transfers = @transfers
        .joins("INNER JOIN members AS sender ON from_member_id = sender.id")
        .joins("INNER JOIN members AS receiver ON to_member_id = receiver.id")
        .where('sender.email = ? AND receiver.email = ?', params[:from_email], params[:to_email])
    else
      @transfers = @transfers
        .joins(:from_member)
        .where('email = ?', params[:from_email])
    end
  elsif params[:to_email].present?
    @transfers = @transfers
      .joins(:to_member)
      .where('email = ?', params[:to_email])
  end
end
```

<!-- tabs:end -->