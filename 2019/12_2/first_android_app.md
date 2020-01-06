# [我的第一个Android APP](/2019/12_2/first_android_app.md)

## 知识盲区

<i class="fa fa-hashtag"></i>
Gradle

\- 我对他的理解暂时是：类似Maven的工具

<i class="fa fa-hashtag"></i>
baseline

安卓组件内文本底部对齐的基准线，在Design模式下右键组件第一个选项就是，

拖动Baseline与另一个组件对齐会让组件自动调整高度使baseline对齐

<i class="fa fa-hashtag"></i>
[toast](https://developer.android.com/guide/topics/ui/notifiers/toasts)

Toast是APP底部黑底白字的消息，比如常见的"无法连接到网络，请检查网络连接"

---

## AS添加版本控制

VCS > Enable Version Control Integration > Git

默认的`.gitignore`不够用，我加了些自己的东西

```
# Java class files
**/*.class
**/*.jar

.idea
.vscode
```

但是第一次commit不小心把全部文件都加了

于是需要untrack/delete added files

先`git rm -r --cached .`"删掉"全部修改完`.gitignore`再`git add .`回来

> [!TIP]
> git diff --staged/cached 可以差分已经add的文件

---

<i class="fa fa-hashtag"></i>
Run APP on an emulator

将APP跑在安卓模拟器上,第一次跑的时候估计开了代理导致socks error，关掉代理重开AS就好了

但是模拟器太耗CPU和内存了，本身我也是用安卓机的，就直接连数据线跑APP就行了

<i class="fa fa-hashtag"></i>
activity_main.xml

UI布局的XML文件最下方可以在Text和Design间切换，我还是习惯看纯文本的xml

Ctrl+Shift+←/→ [toggle between Design and Text](https://stackoverflow.com/questions/20682455/shortcut-to-switch-between-design-and-text-in-android-studio)

Design模式下还可以通过cmd+B跳到Text模式

## ActionBar

￿¶ 隐藏方法: 修改style.xml

> \<style name="AppTheme" parent="Theme.AppCompat.Light.NoActionBar">

> [!TIP|auto_import]
> 写Java代码前最好把IDEA的auto import给启用了，省事

## toast

```java
Button toastButton = findViewById(R.id.toastButton);
toastButton.setOnClickListener(new View.OnClickListener() {
  @Override
  public void onClick(View view) {
    Context context = getApplicationContext();
    CharSequence text = "[Toast]:网络请求失败！请检查您的网络";
    Toast toast = Toast.makeText(context, text, Toast.LENGTH_SHORT);
    toast.show();
  }
});
```

---

<i class="fa fa-hashtag"></i>
打包成apk

不加开发者签名的话，无法上架到谷歌商店，只能以app-debug.apk的形式打包

我是通过idea的find_action->搜索apk 

打包完成后，点击locale会在文件夹窗口打开apk, g完成打包打包后的路径是`app/build/outputs/apk/debug/`

## APK下载链接及功能介绍

- 功能1：输入1个数，计算它的平方(无输入参数验证)
- 功能2：点击最底下的按钮，弹出toast消息

<i class="fa fa-hashtag"></i>
下载链接

[我的第一个APK - 下载链接](http://showmethemoney.sweetysoft.com/image_after_2019_06/1946/my_first_app.apk)

<a href="/assets/apk/my_first_app.apk">我的第一个APK - 下载链接</a>
