# [Android学习路线](/2019/12/android_learn_step.md)

教科书：developer.android.com

辅助视频：

- [Android Tutorial for Beginners](https://www.youtube.com/watch?v=taSwS5rhtmc&list=PLS1QulWo1RIbb1cYyzZpLFCKvdYV_yJ-E&index=3)
- [Android Studio For Beginners Part 2](https://www.youtube.com/watch?v=6ow3L39Wxmg)

<i class="fa fa-hashtag"></i>
学习顺序

- [x] 了解Activity的生命周期
- [x] 在第一个Activity点击按钮，传递参数打开另外一个Activity
- [x] SharedPreferences本地存储(类似浏览器的LocalStorage)，练习当前主题存储
- [x] 访问后台接口，更新当前的Activity(使用OkHttp/Retrofit/Volley请求库)
- [x] 学习gradle的基本知识
- [x] == 开始学习UI
- [x] UI一：学习基本组件(TextView/Button/Spinners)
- [x] UI二：学习常见的布局，例如线性布局、相对布局、绝对布局、recycle布局
- [x] UI三：学习其它UI组件(Loader、ImageView等等)
- [x] 了解Fragment,做出一个轮播图/TabLayout切换Demo
- [x] 学习service
- [ ] 修改安卓style(先不学)
- [ ] ~~(毕业DEMO)加入数字签名打包APK，上架一款SQLite CRUD相关APP到Google Play~~
- [ ] 可以进项目练手了

---

## 零散的Android笔记

### debuggable true

## 开关代理可能导致无法Debug/连虚拟机

Debug和AVD虚拟机都是通过socket与AS连接

如果开着AS的途中网络代理发生变化，会导致无法Debug或连接AVD
