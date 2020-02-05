# [Android底部导航栏](/2020/01/bottom_navigation.md)

## BottomNavigation

我是照抄AS的底部导航栏模板，首先要引入一个包，导航栏**组件**要靠它

`implementation 'com.google.android.material:material:1.0.0`

用的时候我也一步步照着视频做，比如最外层是相对布局，导航栏要alignParentBottom，上面的组件要layout_above...

然而还是有3个Unexpect Behaviour：

1. 只有activated的图标下方才有文字
2. activated已激活项会变大
3. <var class="mark">ripple effect</var>按住按钮(:hover)时，会有一个很丑的圆圈

- 问题1出现的原因：底部导航栏图标数量超过3个以后，就只显示已激活图标的文字
- 问题2出现的原因：谷歌自带的模板本来就是这样
- 问题3出现的原因：模板本来就有，只不过圆圈没有超出导航栏

UB1的解决方法`app:labelVisibilityMode="labeled` [参考stackoverflow](https://stackoverflow.com/questions/40396545/bottomnavigationview-display-both-icons-and-text-labels-at-all-times/47407229)

UB2的解决方法`values/dimens.xml`中插入一行:

> \<dimen name="design_bottom_navigation_active_text_size" tools:override="true" tools:ignore="PrivateResource">12sp</dimen>

UB3的解决方法 `app:itemBackground="?android:attr/windowBackground"`

当我想用`com.android.support:design`的底部导航栏库时，AS又警告不兼容新设备...

所以说谷歌的库未必都是好的，比如Angular，又比如Volley(对比OkHTTP)

做到

> [!TIP|label:ripple]
> 「术语」ripple effect：

---

直到这里 `menu/bottom_navigation.xml` 和 `activity_main.xml` 就写完了

## res/navigation

!> navigation里的ID一定要和`menu/bottom_navigation.xml`<var class="mark">一致</var>

> [!DANGER]
> label属性用来设置ActionBar的标题，几乎没什么用

```xml
<navigation xmlns:android="http://schemas.android.com/apk/res/android"
  xmlns:app="http://schemas.android.com/apk/res-auto"
  xmlns:tools="http://schemas.android.com/tools"
  android:id="@+id/nav_graph"
  app:startDestination="@id/navigation_home">
  <!-- 就id和name属性有用，tools属性的layout会被Fragment的Java代码重定向 -->
  <fragment
    android:id="@+id/navigation_home"
    android:name="com.monitor.exchange.fragment.HomeFragment"
    tools:layout="@layout/items_container" />
</navigation>
```

## Activity中初始化导航栏

MainActivity初始化的导航栏的代码依赖以下两个包

```
implementation 'androidx.navigation:navigation-fragment:2.1.0'
implementation 'androidx.navigation:navigation-ui:2.1.0'
```

将下面的代码放在onCreate中setContentView后

```java
/* 初始化底部导航栏 */
BottomNavigationView bottomNavigation = findViewById(R.id.bottom_navigation_menu);
NavController navController = Navigation.findNavController(this, R.id.navigation_host_fragment);
NavigationUI.setupWithNavController(bottomNavigation, navController);
// 绝大部分App都没有ActionBar，这行几乎没用
AppBarConfiguration appBarConfiguration = new AppBarConfiguration.Builder(R.id.navigation_home,
  R.id.navigation_monitor, R.id.navigation_currencies, R.id.navigation_mine).build();
NavigationUI.setupActionBarWithNavController(this, navController, appBarConfiguration);
```
