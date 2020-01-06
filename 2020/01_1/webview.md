# [webview](/2020/01_1/webview.md)

## webview的三种实现方法

<i class="fa fa-hashtag"></i>
方法1. 

<i class="fa fa-hashtag"></i>
方法2. 无需layout

<!-- tabs:start -->

#### **1.一般用法**

```java
@SuppressLint("SetJavaScriptEnabled")
@Override
public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
  WebView myWebView = Objects.requireNonNull(getView()).findViewById(R.id.webview);
  myWebView.getSettings().setJavaScriptEnabled(true);;
  myWebView.loadUrl("https://modao.cc");
}
```

#### **2.无需layout**

> fragment中无法使用

```java
// Activity的onCreate方法中
WebView myWebView = new WebView(getApplicationContext());
setContentView(myWebView);
myWebView.loadUrl("https://www.raspberrypi.org/");
```

#### **3.渲染HTML字符串**

> 调用接口返回html字符串，通过方法3进行渲染

```java
String unencodedHtml = "<h1>apple</h1>";
String encodedHtml = Base64.encodeToString(unencodedHtml.getBytes(),
        Base64.NO_PADDING);
myWebView.loadData(encodedHtml, "text/html", "base64");
```

<!-- tabs:end -->

[安卓webview文档](https://developer.android.com/guide/webapps/webview)
的第四部分内容是关于js中调用java代码，这是ReactNative源码级别的研究，先不用看

webview最后的内容是，浏览历史记录、链接也通过webview打开而非系统浏览器，项目上也用不到
