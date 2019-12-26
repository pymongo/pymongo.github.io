# [构建接口测试样例数据](/2019/12_1/rspec_test_example.md)

不想再用swagger/postman人肉地点击POST/GET，低效且测试得

V站有人发问[后端写接口都不自测的吗](https://www.v2ex.com/t/625803)

想起我昨天写的接口被安卓的同事质问"你能不能自己先测试再把接口给我"

摘抄一条回复，跟我司CTO一样的接口开发流程

## 接口开发流程

```
先不考虑网络异常、业务异常等问题，
先在客户端（前端）把完整的数据交互流程完整开发出来，
涉及数据请求的地方，先用「假数据」或者利用客户端本地数据库模拟一套数据管理系统以及相关接口，
也就是模拟实现一套数据持久层与请求层。如果是网页应用，可以用 indexdDB，其它平台则推荐 sqlite。
前一步完成之后，再在基础的数据交互场景之上「穷举」所有可能要处理的非核心业务的数据交互场景
，并整理接口文档后端。根据文档开发接口，严格按前端的要求来。
总之就是一句话，房子要从下往上建，而不能从楼顶开始。
```

1. 先「穷举」出所有可能要用到的接口
2. 约定好每个接口的入参和返回参数，返回的数据先填上lorem假数据
3. 考虑每个接口的交互场景：如哪些接口需要登录后才能获取，有些用户在前端不可能点击到的接口就不需要考虑那么周全
4. 用逻辑树状图/脑图「穷举」接口尽可能多的可能的接收数据，写接口单元测试，不要依赖postman
5. 编写相应单元测试的代码
6. 开发接口代码，重构接口代码

## 创建测试数据库

完美地解决Mysql数据库编码格式的方法是，通过rake创建数据库

1.rake db:create

> bundle exec rake db:create `RAILS_ENV=test`

2.列出所有数据库的编码格式，检查测试数据库编码：

```sql
SELECT schema_name,default_character_set_name FROM information_schema.SCHEMATA;
```

3. bundle exec rake db:migrate `RAILS_ENV=test`

## rspec文件

<i class="fa fa-hashtag"></i>
rspec文件结构

```ruby
describe '移动端'
  include ModuleA
  context '底部广告接口' do
    before (:each) do
    end
    # before :all 只会执行一次
    before :all do
      # 创建测试用例(xx表新增一个记录)
    end
    after :all do
      # 删除测试用例
    end

    it '如果用户没登录'
    end
  end
end
```

测试流程

## 读接口json需要转为symbol

Hash有两个API可以递归地把所有key转为symbol/string

`stringify_keys` 和 `symbolize_keys`

将response处理后，就方便与测试的期待值进行比较

(>_<我曾经花了大半天搞才悟出来的)
