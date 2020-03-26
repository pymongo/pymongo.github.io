# [android view binding](/2020/03/android_view_binding.md)

view binding需要gradle3.6.x以上版本的支持，[文档](https://developer.android.com/topic/libraries/view-binding#java)

使用：

gradle中启用view binding

```
viewBinding {
  enabled = true
}
```

在Activity中如何使用：

```java
super.onCreate(savedInstanceState);
binding = LoginActivityBinding.inflate(getLayoutInflater());
setContentView(binding.getRoot());

binding.loginButton.setOnClickListener(v -> {
  final String username = binding.username.getText().toString();
  final String password = binding.password.getText().toString();
  if (username.isEmpty() || password.isEmpty()) {
    UiOperation.toastCenter("用户名和密码不能为空");
    return;
  }
  OkHttpHelper.get(ApiUrl.LOGIN, new HashMap<String, String>() {{
    put("username", username);
    put("password", password);
  }}, response -> {
    try {
      JSONObject apiData = new JSONObject(response);
      if (apiData.getInt("status_code") != OkHttpHelper.CODE_SUCCESS) {
        return;
      }
      SharedPreferencesHelper.setBoolean("is_login", true);
      startActivity(new Intent(LoginActivity.this, MainActivity.class));
    } catch (JSONException e) {
      Log.e(TAG, Log.getStackTraceString(e));
    }
  });
});

```

优缺点：

+ 不用指定组件id的View类型，不用担心空指针问题
\- 不能找到include中的组件id
\- 相比data binding功能更弱，适用于简单逻辑的页面

## 仅用于UI预览的文案显示

you can add tools:text to specify some text for the layout preview only.

应该是只会在UI预览中显示，实际的显示效果为空
