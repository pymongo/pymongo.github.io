# [使用Room操作SQLite](/2020/01_1/sqlite_room.md)

验证代码成功修改了安卓的SQLite，我认为有几个方法：打log、安卓自带的SQLite Viewer、

adb连上SQLite、安卓端或PC端的SQlite可视化工具等等，我还是喜欢打log

<i class="fa fa-hashtag"></i>
去掉log中无用的前缀，提高信噪比

如`2020-01-08 20:18:34.040 20145-23939/com.monitor.exchange`这种前缀不该出现在log中

[Hide datetime in android log](https://stackoverflow.com/questions/18125257/how-to-show-only-message-from-log-hide-time-pid-etc-in-android-studio)

