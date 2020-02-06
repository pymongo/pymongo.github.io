# [安卓websocket实现聊天功能](/2020/02/android_websocket.md)

[okhttp的官方demo](https://github.com/square/okhttp/blob/master/samples/guide/src/main/java/okhttp3/recipes/WebSocketEcho.java)
看完后只能写出一个在websocket类中能发websocket，在别的Class中又调用不了，这样写代码没法复用reuse啊

我最后通过`okhttp websocket callback`这样的关键词组合找到了想要的搜索结果

[Android.os.handler+interface](https://github.com/fedepaol/websocket-sample/blob/master/app/src/main/java/com/whiterabbit/websocketsample/websocket/ServerConnection.java)

通过Android.os.handler+interface实现了传参"codeBlock"

也就是说把websocket的OnMessage回调消息处理，扔给使用ws工具类的class去解决

[android websocket](https://fedepaol.github.io/blog/2017/04/30/android-okhttp-and-websockets/)