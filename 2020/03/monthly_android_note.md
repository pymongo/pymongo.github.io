# [安卓每月小知识积累](/2020/03/monthly_android_note.md)

<i class="fa fa-hashtag"></i>
tools:text仅用于预览模式的文案显示

调试UI布局时常常需要TextView上显示一些文案看看效果，但是在实际的安卓App里这个TextView的文字是通过请求接口返回的

最佳实践是使用tools:text定义仅用于UI预览下显示的文案

<i class="fa fa-hashtag"></i>
在布局xml的root element中按Alt+Enter可以转为data binding

<i class="fa fa-hashtag"></i>
<var class="mark">logt</var>自动生成`private static ... TAG = "xxx";`

<i class="fa fa-hashtag"></i>
Method separators

Intellij可以设置函数间的分隔线，这样看代码时将注意力集中在某一段函数，搜索Method separators

<i class="fa fa-hashtag"></i>
Context Menu(长按弹出菜单复制聊天消息)

第二次见到这个KeyWord，以前用windows修改context Menu(右键菜单)时了解过context menu

不过这次我是实现长按复制聊天消息的需求

```java
// OnLongClickListener
@Override
public void onCreateContextMenu 

@Override
public boolean onContextItemSelected (MenuItem item) {
```

<i class="fa fa-hashtag"></i>
(Adapter)在itemOnClick中执行Activity的方法

虽然可以通过Interface的方式让Activity文件中定义点击事件

但是现在提供另一种解决办法：将view.getContext转换为所需的Activity类型

```java
holder.itemView.setOnClickListener(view -> {
  Intent intent = new Intent();
  intent.putExtra("country_code", dataSet.code);
  CountryCodesActivity activity = (CountryCodesActivity)view.getContext();
  activity.setResult(Activity.RESULT_OK, intent);
  activity.finish();
});
```

<i class="fa fa-hashtag"></i>
onAttachedToRecyclerView

似乎有些鸡肋，要想传参在Adapter构造方法中传也行啊。用处似乎是让Adapter获取reclycerView对象

<i class="fa fa-hashtag"></i>
Parcelable(序列化传输java实例对象)

类似JDK的Serializable接口，用于序列化传输Java实例对象

Parcelable有点复杂，我单独写篇文章

See Also: ObservableParcelable

<i class="fa fa-hashtag"></i>
onTouchListener

实现按住时背景颜色改变，松开时又恢复的效果

<i class="fa fa-hashtag"></i>
SearchView踩坑总结

1. 不要用android.widget.SearchView，很多属性多不能用
2. iconifiedByDefault="false"使整个SearchView可点击而非单个搜索图标可点击

<i class="fa fa-hashtag"></i>
64k方法数限制

APK文件限制了单个.dex文件最多引用的方法数是65536个，解决方案：MultiDex

<i class="fa fa-hashtag"></i>
./gradlew lint

检查未使用的资源，检查代码质量等等