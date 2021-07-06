# [Java的volley网络请求库](/2020/01/volley.md)

说起Java的网络请求库，比较知名的是OKHttp，还有Java自带的java.net.HttpURLConnection

鉴于谷歌的安卓文档极力推荐谷歌开源的volley库，于是我就先学它了:joy:😂

## 导入包后要"npm install"(sync)

<i class="fa fa-hashtag"></i>
导入volley步骤1：

`app/build.gradle`的`dependencies`项目中加入一行

`implementation 'com.android.volley:volley:1.1.1'`

上面的代码去掉\就行了，因为docsify会把冒号+单词+冒号解析为<var class="mark">Emoji Shortcodes</var>

别以为这就完了，步骤1只是新增了一个包，就像在Gemfile或package.json里加了一行

还需要第二步<var class="mark">npm install</var>才能把新的包下载到项目里

<i class="fa fa-hashtag"></i>
导入volley步骤2：

`./gradlew --recompile-scripts` sync without building anything

list task `./gradlew tasks`

我是直接用AS停止按钮右边的蓝色小象按钮进行"npm install"：

<var class="mark">Sync Project with Gradle Files</var>

可以暂时的把gradle理解为rake(task) + Gemfile的结合体 

<i class="fa fa-hashtag"></i>
导入volley步骤3：允许app访问网络与允许明文的网络请求(如HTTP)

`AndroidManifest.xml`加入APP允许访问网络的权限配置，与application平级，在application上面

> \<uses-permission android:name="android.permission.INTERNET" />

`AndroidManifest.xml`的application新增以下属性允许明文网络请求

> android:usesCleartextTraffic="true"

## response.toString(2)

volley默认是异步请求

最佳实践：在onResponse的回调中，将网络请求得到数据进行列表渲染

Log.e(TAG, response.toString(<var class="mark">2</var>))

JSONObject.toString方法的第一个参数是indentSpaces，用于pretty print json

---

<i class="fa fa-hashtag"></i>
volley的优点

1. 代码里少，可读性强(缺点是配置项不多)
2. 可以在异步请求的回调中更改view(OkHttp不能)

但是就因为okhttp速度更快，用的人多遇到问题能找到答案，所以项目中还是得用OkHttp

## volley的post请求

比较恶心/不合常理的是，post请求的参数居然要写在response回调的下面？

```java
JsonObjectRequest sendChatMessage(String chatMessage) {
  return new JsonObjectRequest(Request.Method.POST,
    Urls.SEND_MESSAGE, null, response -> {
  }, error -> {
  }
  ) {
    @Override
    public byte[] getBody() {
      return new HashMap<String, String>() {{
        put("message", "HellowWorld");
      }}.toString().getBytes();
    }
  };
}
```
