# [Android Studio](/archive/intellij_idea/android_studio.md)

## 文件导航栏

~~文件导航栏不要选Android，要选project类型才能列出所有文件~~

文件导航栏要选默认的Android，如果用Project(也就是真实的文件结构)，

资源文件夹会很乱，参考: separate-mipmap-folders-in-android-studio - stackoverflow

UI布局的XML文件最下方可以在Text和Design间切换，我还是习惯看纯文本的xml

Ctrl+Shift+←/→ [toggle between Design and Text](https://stackoverflow.com/questions/20682455/shortcut-to-switch-between-design-and-text-in-android-studio)

Design模式下还可以通过cmd+B跳到Text模式

## cmd+;配置SDK

cmd+; = `project structure`(配置JDK、SDK等等)

## 自动生成代码

<i class="fa fa-hashtag"></i>
匿名内部类的代码自动生成

`button.setOnClickListener(new V`

打到这里时，自动补全下拉菜单第一个选项有个大写I的图标

此时一定不要按`Tab` 而是按 `Enter`完成匿名内部类的代码自动生成

logd -> Log.d(TAG, "onCreate: ");

logt -> private static final String TAG = "xxx";

---

在xml中，可以输入"<Tex"就能生成TextView组件的代码