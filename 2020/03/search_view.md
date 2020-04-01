# [安卓搜索栏SearchView](/2020/03/search_view.md)

\<SearchView踩坑总结>
1. 不要用android.widget.SearchView，很多属性多不能用
2. iconifiedByDefault="false"使整个SearchView可点击而非单个搜索图标可点击
3. TODO 当搜索栏失焦时cursor光标依然在闪

> 实现搜索功能的核心是给SearchView加setOnQueryTextListener

```xml
<androidx.appcompat.widget.SearchView
  android:id="@+id/search_view"
  android:layout_width="match_parent"
  android:layout_height="wrap_content"
  app:iconifiedByDefault="false"
  app:queryHint="请输入搜索内容" />
```

```java
binding.searchView.setOnQueryTextListener(new SearchView.OnQueryTextListener() {
  @Override
  public boolean onQueryTextSubmit(String query) {
    // Ignore
    return false;
  }

  @Override
  public boolean onQueryTextChange(String newText) {
    if (bean == null) {
      return false;
    }
    List<DataSet> newDataSets = new ArrayList<>();
    DataSet dataSet;
    for (int i=0; i<bean.dataSets.size(); i++) {
      dataSet = bean.dataSets.get(i);
      if (dataSet.name.contains(newText)) {
        newDataSets.add(dataSet);
      }
    }
    binding.setDataSets(newDataSets);
    return true;
  }
});
```

遗憾的是当🔍搜索栏失去焦点时(onBlur)，光标依然在闪烁
