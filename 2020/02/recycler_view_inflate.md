# [recyclerView正确的渲染方法](/2020/02/recycler_view_inflate.md)

接手前同事写的安卓代码后，进入某个页面后经常出现如下的Error级别的日志

> E/RecyclerView: No adapter attached; skipping layout

原因是旧代码几乎都在网络请求response初始化recyclerView的adapter

导致初始化页面跳过了recyclerView的渲染

旧代码中更严重的是recyclerView的渲染(inflate)完全是错的，

导致更新recycleView的数据时一直闪退

> java.lang.IllegalStateException: The specified child already has a parent. You must call removeView() on the child's parent first.

参考了[谷歌的相关教程](https://developer.android.com/guide/topics/ui/layout/recyclerview)
以及[Android widgets samples](https://github.com/android/views-widgets-samples/tree/master/RecyclerView)

<!-- tabs:start -->

#### ** 正确的inflate **

```java
  @Override
  public ViewHolder onCreateViewHolder(@NonNull ViewGroup viewGroup, int viewType) {
    View view = LayoutInflater.from(viewGroup.getContext())
      .inflate(R.layout.item_otc_advertisement, viewGroup, false);
    return new ViewHolder(view);
  }
```

#### ** 错误的inflate **

```java
  public Adapter(Context context) {
    this.context = context;
  }

  @NonNull
  @Override
  public ViewHolder onCreateViewHolder(@NonNull ViewGroup viewGroup, int i) {
    Log.e("onCreateViewHolder", this.tradeTypeName);
    View view = View.inflate(context, R.layout.item_otc_advertisement, viewGroup);
    return new ViewHolder(view);
  }
```

<!-- tabs:end -->
