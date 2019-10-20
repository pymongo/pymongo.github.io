# rails步骤记录

### rails.脚手架顺序
可用自带的脚手架scaffold，自动迁移数据库和生成页面/单元测试等

!> 建议试着自己写，去实现脚手架同样CRUD的功能

步骤顺序：
1. rails new blog -d mysql && cd blog
2. cd blog
3. bundle # init "./bundle"
4. vi config/database.yml # enter mysql password
5. bundle exec rake db:create #【bundle exce】like【npm run】
6. bundle exec rails g scaffold students name:string password:string age:integer