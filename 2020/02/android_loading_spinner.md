# [安卓显示loading动画](/2020/02/android_loading_spinner.md)

首先感谢下Stack Overflow的[这个问题](https://stackoverflow.com/questions/3225889/how-to-center-progress-indicator-in-progressdialog-easily-when-no-title-text-pa)
以及对我而言[有用的回答](https://stackoverflow.com/a/42878518/9970487)

首先需要用到的组件是ProgressBar，默认就是loading转圈圈的样式

首先安卓的绝对布局以及@deprecated了，因为不能适配不同尺寸的屏幕

而且在layout文件加上ProgressBar并不能做出禁止用户点击loading动画图层的效果

所以Stack Overflow上的大伙都推荐使用ProgressDialog

!> 注意：ProgressDialog也是被弃用的组件(@deprecated)

---

ProgressDialog的显示效果类似MIUI的「正在关机」的对话框，左边是loading转圈圈的spinner，右边是「正在关机的文案」

我希望做成像element-ui的loading组件那样，将loading spinner居中显示而且不需要文字

网上有很多自定义ProgressDialog的方法，但我认为样式问题就该交给style.xml去解决

好在有人给出可以override`android:Theme.Material.Dialog`的居中弹框的样式

只需重写windowBackground样式并设为透明，即可实现居中的loading弹窗

```xml
  <!-- 居中样式的loading spinner(用于ProgressDialog) -->
  <!-- TODO 该loading样式在小米机型上很丑，带箭头而且不会转动 -->
  <style name="loading_dialog_center" parent="android:Theme.Material.Dialog">
    <!-- loading spinner的颜色设置为bootstrap btn-primary的蓝色 -->
    <item name="android:colorAccent">@color/colorPrimary</item>
    <item name="android:windowBackground">@color/transparent</item>
  </style>
```

```java
  ProgressDialog loading = new ProgressDialog(this, R.style.loading_dialog_center);
  loading.setCancelable(false);
  loading.show();
  // do something ...
  loading.dismiss();
  loading = null;
```

## loading演示gif

![android_loading_spinner.gif](android_loading_spinner.gif)

---

我提了一个[suggest edit](https://stackoverflow.com/review/suggested-edits/25291010)
去改善[loading动画的回答](https://stackoverflow.com/a/42878518/9970487)

不过被android分区给拒绝了(2票拒绝，1票同意，review没通过)，🤕review没通过

![stackoverflow_suggest_edit_was_rejected](stackoverflow_suggest_edit_was_rejected.png)
