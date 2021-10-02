# [底部导航栏页面切换的坑(socket)](/2020/04/navigation_lifecircle.md)

BottomNavigationView切换Fragment时流程有点「特殊」

例如页面A->页面B时流程如下：

1. 页面B.onCreateView()
2. 页面B.onResume()
3. 页面A.onPause()

似乎跟TabLayout切换Fragment时的生命周期顺序不同，TabLayout切换tab时似乎是调用了FragmentManager的Replace方法(存疑)

androidx的底部导航栏导致我开发的安卓App出现了生产事故

我之前的代码是Fragment1在onPause时会把页面1的socket回调清空(设为null)同时取消订阅页面1的所有频道

结果通过底部导航栏从页面1切换到页面2时，所有socket的监听回调就没了

打log后发现(主要是给listener的setter方法打log，以及给两个页面的生命周期打log)

先走页面2的onCreateView、onResume并将websocket的回调设为页面2的回调方法

结果页面2走到一半，执行了页面1的onPause方法把socket回调清空了

解决方案：

4个底部导航栏的Fragment离开时就不进行清空socket回调和取消订阅的操作了

取消订阅放在MainActivity(导航栏所在Activtity)

并且在4个Fragment各自的socket回调中都加上一个判断

```java
WebSocket.getInstance().setListener(message -> {
  if (isDetached()) {
    Log.w(TAG, "[Wrong Listener]HomeFragment isn't showing, but HomeFragment's listener is using");
    return;
  }
// ...
```
