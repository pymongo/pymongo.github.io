# [adb从手机中导出apk](/2020/01_1/adb_export_apk.md)

<i class="fa fa-hashtag"></i>
通过alias将adb添加到环境变量中

> alias adb="/Users/w/Library/Android/sdk/platform-tools/adb"

<i class="fa fa-hashtag"></i>
adb列出所有已安装的包名

> adb shell pm list package

<i class="fa fa-hashtag"></i>
adb打印屏幕录制器的绝对路径

> adb shell pm path com.miui.screenrecorder


<i class="fa fa-hashtag"></i>
adb将手机中的apk文件下载到本地

> adb pull /data/app/com.miui.screenrecorder.apk ~/Downloads/com.miui.screenrecorder.apk

adb折腾了半天只为了把MIUI的屏幕录制app导出来给魅族，结果在魅族上又不兼容安装不了...，搞半天才发现魅族系统的屏幕录制在通知栏的下拉菜单工具箱里

[参考链接](https://stackoverflow.com/a/18003462/9970487)
