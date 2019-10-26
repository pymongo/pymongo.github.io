# rails步骤记录

★尽量养成习惯用bundle exce rails/rake 而不是bin/rails或rails

## MySQL

### MySQL.schema

> [!NOTE|label:mysql-get_table_schema]
> describe tableName;

### 多对多

多對多關連的概念大概就有點像這樣，沒辦法單純的在兩邊的 Model 設定 has_many 或 belongs_to 就搞定，多對多的關連通常會需要一個第三方的資料表來存放這兩邊 Model 的資訊，也就是上面例子裡「挂号记录」的概念。

!> 「多對多」關連，在使用上就跟一般的「一對多」差不多，但實際上的資訊都是記錄在第三方資料表裡。

這裡的 store:references 的寫法會多做幾件事：

1. 自動加上索引（index），加快查詢速度。
2. 自動幫 Model 加上 belongs_to

## rails.脚手架顺序
可用自带的脚手架scaffold，自动迁移数据库和生成页面/单元测试等

!> 建议试着自己写，去实现脚手架同样CRUD的功能

步骤顺序：
1. rails new blog -d mysql && cd blog
2. cd blog
3. bundle # init "./bundle"
4. vi config/database.yml # enter mysql password
5. bundle exec rake db:create #【bundle exce】like【npm run】
6. bundle exec rails g scaffold students name:string password:string age:integer

## generate migration(增删除字段)

可通过rails g migration appname 字段

实现更新表结构/字段

## candidates app

> [!TIP]
> candidate可首字母大写，不大写生成ruby的类时也会自动大写


1. 在config/routes.rb加上 resources :candidates
2. rake db:create
3. rails generate/destroy controller candidates
4. rails generate model candidates name party votes:integer

!> 注意Model的candidate用单数形式

第4.步后会在/db/migrate/里面生成一个 xxx_create_candidates.rb

打开它可加上一些默认值或约束等

5. rails db:migrate
6. touch index/new/edit.html.erb in views/candidates/
7. add "def index\n@candidates = Candidate.all\n end" in candidates_controller.rb
8. add controller.new and new.html.erb

20. rails generate model vote_logs candidate:references ip:string

## refactor

### before_action

> before_action :set_candidate, :only => [:edit, :update]

类似python的装饰器，这个函数能让后面指定的函数的第一行加上公用函数的内容

```ruby
def set_candidate                                                                                                                     
    @candidate = Candidate.find params[:id]
end
```

主要作用是根据ID选中数据库某行并赋值给实例变量，以便进一步修改


## views

### render

render plain: "<h1>No html!</h1>"

> [!TIP|label:string.html_safe]
> render html: %Q(<a href="/candidates">/candidates</a>).html_safe

render inline: "<h2>inline=render as html.erb</h2>"

render xxx and return

<%= form_for(@candidates) do |f| %>
<%= form_for(@candidate) do |f| %>