# [安卓通过sharedPreference切换主题](/2019/12/android_change_theme.md)

[Save key-value data - developer.android.com](https://developer.android.com/training/data-storage/shared-preferences)

安卓改变主题的方法<var class="mark">setTheme</var>必须放在**View**被渲染之前

也就是在`super.onCreate`与`setContentView`之间

这意味着 通过ToggleButton/Switch按钮切换主题后，还要刷新页面才能生效

所以修改主题的流程变为：

1. 点击按钮修改sharedPreference的主题字段
2. 如果字段发生变化，刷新页面
3. 渲染view之前，先读取sharedPreference的主题字段，并存为isDarkTheme
5. setTheme
6. setContentView
7. 设置完主题后，让View的一些文案与当前主题一致，如标题、ToggleButton的状态

<!-- tabs:start -->

#### **初始化**

```java
public class MainActivity extends AppCompatActivity {

  SharedPreferences configSP;
  boolean isDarkTheme;
  ToggleButton toggleTheme;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
  // ...
```

#### **Toggle按钮**

```java
toggleButton.setOnCheckedChangeListener(new CompoundButton.OnCheckedChangeListener() {
  @Override
  public void onCheckedChanged(CompoundButton buttonView, boolean isChecked) {
    if (isChecked) {
      // step.1 修改配置
      configSP.edit().putBoolean("darkTheme", true).apply();
      // step.2 如果配置项有变化Reload Activity使主题修改生效
      if (!isDarkTheme) {
        finish();
        startActivity(getIntent());
      }
    } else {
      // step.1 修改配置
      configSP.edit().putBoolean("darkTheme", false).apply();
      // step.2 如果配置项有变化Reload Activity使主题修改生效
      if (isDarkTheme) {
        finish();
        startActivity(getIntent());
      }
    }
  }
});
```

#### **读取配置设置主题**

```java
super.onCreate(savedInstanceState);
configSP = getSharedPreferences("config", MODE_PRIVATE);
// SharedPreferences获取值的方法都有默认值，不需要通过.contains判断key是否存在
isDarkTheme = configSP.getBoolean("darkTheme", true);
if (isDarkTheme) {
  setTheme(R.style.Theme_AppCompat);
} else {
  setTheme(R.style.Theme_AppCompat_Light);
}
// setTheme is Before setContentView
setContentView(R.layout.activity_main);
// 设置完主题后，让View的一些文案与当前主题一致，如标题、ToggleButton的状态
setTitle(TAG+"当前主题："+(isDarkTheme ? "黑暗主题" : "白色主题"));
// View初始化完后，让主题的toggleButton状态与isDarkTheme一致
toggleTheme = findViewById(R.id.button4);
toggleTheme.setChecked(isDarkTheme);
```

<!-- tabs:end -->

<i class="fa fa-hashtag"></i>
相关链接

- [Reload activity in Android](https://stackoverflow.com/questions/3053761/reload-activity-in-android)
