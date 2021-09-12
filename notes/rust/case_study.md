# Rust采坑记(案例分析)

记录我工作中遇过的坑以及生产事故，不仅仅是Rust语言相关的坑和事故(虽然我大部分工作内容都是Rust开发)

## rails - 注释掉了登录验证方法

```
案例发生时间: 2019年12月
严重性和损失预估: 生产事故(持续1周，用的人少1-2周后才发现出问题)
事故原因: 接手同事A写的Rails项目，开发环境登录跳转SSO/CAS单点登录总失败，于是注释掉登录验证改为固定账号登入去测试Rails网页修改效果，不小心把不该提交的模块代码也提交了
教训: git add .时一定要很清楚自己改了哪些代码，可以git diff确认下改动内容
```

## android - BottomNavigationView切Fragment时丢掉了WebSocketListener

```
案例发生时间: 2020年4月
严重性和损失预估: 生产事故(持续3-4小时，用户某些功能无法使用，没给公司造成像偷币那样的直接经济损失)，安卓端币币交易页面WebSocket出问题无法使用
事故原因:
    换了底部导航栏和WebSocket库之后
    BottomNavigationView切换Fragment时流程有点「特殊」，例如页面1->页面2时流程如下:
    1. 页面2.onCreateView
    2. 页面2.onResume
    3. 页面1.onPause
    所以不能在页面1的onPause中清空回调监听，不然会把页面2辛辛苦苦设好的listener清掉
    首页三个Tab页都是共用market_list频道，不需要在Fragment切换时取消订阅
    只需在离开MainActivity时取消订阅所有频道即可
解决过程: 先推送上个版本的apk的强制更新(回滚)，不断地打log直到发现底部导航栏切换Fragment的生命周期中会丢掉WebSocket的onMessage回调
教训: 出生产事务时应立即停止吃饭去回滚代码，leader没吃午饭在Debug的时候，我居然有时间去吃饭，自己写错代码害得leader背锅没吃午饭
```

## async - 异步runtime内要用异步的Mutex

```
案例发生时间: 2020年4月
严重性和损失预估: Rust撮合系统开发阶段困难，如果无法解决会让leader砍掉写了1-2个月的Rust项目
解决过程: 打log发现异步函数运行有点无序，Task1调用A函数成功获取Mutex锁
教训: 出生产事务时应立即停止吃饭去回滚代码，leader没吃午饭在Debug的时候，我居然有时间去吃饭，自己写错代码害得leader背锅没吃午饭
```

## 夏令时(daylight saving time)问题(感谢两位推友帮我解决了两个夏令时问题)

笔记: 首先中文把dst(daylight_saving_time)翻译成夏令时+冬令时是不太准确的

首先可以说美国就没有冬令时，或者说冬令时就是标准时间，而夏令时就是把时间调快1小时

因为C语言的strut tm的isdst字段也就一个bool,所以只有是夏令时和不是夏令时，没有冬令时的说法

夏令时开始于3月的第二个周日的凌晨2点，结束于11月的第一个周日的凌晨2点

案例发生时间: 2020年6月
案例问题: 撮合引擎创建的很多订单，在网页上查询订单创建时间都多了1小时
严重性和损失预估: 因为trades表订单的created_at变快1小时，导致k线图全乱了(生产事故)，要靠人工改数据库trades表问题订单的created_at才解决，降低了领导对Rust项目的信心
原因: 因为我们MySQL表上created_at等时间戳字段是存入服务器当地时间的信息的，所以actix_web启动前要先用chrono API获取到当地时区
然后让sqlx每次写数据时都加上
解决问题的commit: tase-matcher 855ba28da9e2ca791a32962d128e15941a5cbc32

Rust嵌入式大佬王momo的提示： https://twitter.com/andelf/status/1276470803387740160

```
你这个用错了。如果获取 unix timestamp=0 的话，那么会收到夏时的影响。所以需要明确"当前时差"和"历史某一时刻时差" 的影响， 所以需要用 offset_from_utc_date ，传递 now()  做参数。 像BJT/CST这种没有夏时制影响的时区实在太惯着程序员的
```

听从建议后我的代码改动如下

```
-    let timezone = chrono::Local.timestamp(0, 0).offset().to_string();
+    let timezone = chrono::Local::now().offset().to_string();
```

但如今我回头看，依赖chrono去查时区是不可靠的，文档上也没太多介绍某某api会不会受到夏令时影响

更好的解决方案是用C语言的localtime_r或gmtime都可以获取时区，还有isdst字段判断获取的时区有没有受到夏令时影响

最好的解决方案是既然sqlx和active_record等连接池默认都是UTC时区，那数据库的datetime类型就不要存入时区信息，用类似postgres或sqlite的datetime_without_timezone

---

案例发生时间: 2021年3月底
案例问题: instagram的api为什么会在2021-03-15这天发生时间戳变化?
严重性和损失预估: 因为assert了每天都会有24小时的online_followers数据，冬令时->夏令时切换那天返回的数据长度时23导致线程panic
```
https://twitter.com/ospopen/status/1376708885260554241
多谢提醒，facebook把Daylight Saving Time也算进时间戳
api的服务器在UTC-8时区，每天在硅谷当地时间0点采集数据

所以3月14日时间戳是08:00(因为还没到当天凌晨2点切换成夏令时)，到了3月13日时间戳是07:00(夏令时调快1小时)
online_followers每小时采集一次的数据在3月15日只有23个小时数据
最近遇到该接口返回长度不等于24导致panic
```

解决方案: 测下online_followers API传入数据长度为23和25的数据会不会报错

## 集成测试不发短信和邮件 - 乱发邮件容易提高Amazon SES拒信率

```
案例发生时间: 2020年11月
严重性和损失预估: 可能会增加Amazon SES的因拒信率提升而停掉公司的服务
事故原因:
    集成测试中随机生成新用户的邮箱在对方域名下可能不存在这个用户，
    于是对方域名的风控系统就会告诉SES你们的某某乱发邮件，都是发给不存在的用户，可能是广告或滥用
    于是SES得到返回后就会怀疑我们在用SES乱发广告，拒信率有点高，最终停掉我们的SES服务
    集成测试里乱发邮件，不仅可能导致对方域名将我们拉黑或spam掉，还可能导致SES停掉我们服务
解决方案:
    1. 测试账号应用"test+${随机字母数字}@${公司域名}"格式的邮箱，不要用别人的域名
    2. 测试环境应该不需要发任何邮件和短信，email_sender应添加过滤器email.starts_with(TEST_EMAIL_PREFIX) && email.ends_with(TEST_EMAIL_SUFFIX)
    3. 对于重置密码邮件发送接口的测试，应当独立开发一套仅限127.0.0.1访问的私有API，这些私有API仅仅能查询满足测试账号邮箱格式的邮件激活码
    4. 生产环境部署后，需要一些普罗米修斯之类的第三方运维监控平台，它们要求我们的服务器提供相应的API，可以在warp框架设置request防火墙
教训: 前几天才看到一个v2ex的帖子说测试环境不能发真实短信和邮件，怎么就不长记性？
```

## mongodb update_one没写$set导致更新时丢失其它字段

案例发生时间: 2021年3月
解决方法: 肉眼review了所有改动jobs表的方法，没看出来问题，加上类似MySQL非空约束的mongodb validation后，看到错误日志中remove_jobs方法报错才找到错误的update_one查询

```
{
  $jsonSchema: {
    required: [
      'token',
      'queue',
      'jobs',
      'connected_jobs_size',
      'created_at',
      'updated_at'
    ]
  }
}
```

修复Bug的代码改动:

```
     pub async fn remove_jobs(&mut self, db: &Database) -> Result<()> {
-        let id_query = doc! {"_id": self.igb_id};
-
         self.updated_at = Utc::now().into();
         db.collection(INSTAGRAM_JOBS)
-            .update_one(id_query, doc! {"jobs": []}, None)
+            .update_one(
+                doc! {"_id": self.igb_id},
+                doc! {
+                    "$set": {
+                        "jobs": [],
+                        "updated_at": self.updated_at.0
+                    }
+                },
+                None,
+            )
             .await?;
```

## loop-select! 不完全等同于 while-let-some

```
Bug 2021-08 月底
Bug 持续时间: 2 周
Bug 损失和影响:
  CPU 占用率在启动后暴涨，浪费高级别的员工的时间去 debug
  至少浪费 3-4 个 P6 级别以上的同事，至少浪费 10 人日的「人工」
  降低部门全体员工对我的印象，严重影响了试用期转正评级
  让领导第三次暗示我研发你搞不顶要不你转岗或试用期不通过
事故的标签: regression/revert, 本来同事的代码是对的被我改错了

复盘我的所有犯错:
1. 为了能让 store graceful shutdown 开始乱加 shutdown receiver
   在我完全不懂 peer_communication.rs 代码的背景下
   居然把 rpc XXX(stream Msg) returns (...) {} 的代码改掉
   实际上只需要在 peer 和 recover 两个 tonic rpc server 改成 graceful shutdown 就行了
2. 甩锅，多次抱怨「之前同事写的代码就有问题，与我无关」
3. 自以为是，嘴硬，多次强调「loop-select 跟 while-let-some」一样
   实际上，如果 stream 是无限长的，这两确实一样
   但分布式节点间通信的 stream 的长度是固定的
   导致代码陷入 loop-None 死循环
   如果是有限长度的 stream 应该用 loop-select-if-some-else-break 达到 while-let-some 等价效果
4. 专注力不够，做事情不够 focus 跟部长加班 debug 时注意力老是被其它东西分散
```
