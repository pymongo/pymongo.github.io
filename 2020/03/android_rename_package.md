# [安卓解决重命名包名后IDE报错的办法](/2020/03/android_rename_package.md)

重命名包名的步骤(以com.example重命名为org.chat为例)：

1. Clean Project
2. 新建文件夹org
3. 右键com.example文件夹，Refactor->Move Package
4. 在Move Package选中刚刚新建好的org文件夹，点击Do Refactor
5. 此时包com.example会变成org.example，删掉空的com.example文件夹
6. 右键org.example文件夹，Refactor->Rename为org.chat

虽然代码完成了重构与重命名，但是IDE还是给很多类标红报错

需要[Invalidate cache/restart ](https://stackoverflow.com/questions/29492791/android-studio-fails-to-build-after-package-name-refactor)
清除IDE对旧包名的缓存才能解决IDE can not resolve XXX 的报错

1. Clean Project
2. Invalidate cache/restart
3. Build Project
