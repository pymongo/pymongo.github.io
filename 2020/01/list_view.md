# [Android - ListView](/2020/01/list_view.md)

<i class="fa fa-paragraph"></i>
内心独白

从学习安卓到2019年的🎄都快3周了，依然不能对接上项目的接口

想要对接之前还得学个ListView组件把请求接口返回的数据漂亮地小时出来

要是用ruby我一天都能写完4个接口并且加上单元测试了，然而我以为我有后端基础安卓能学得快点

结果还是进展缓慢，我还指望过年前对接websocket。

于是今晚对自己狠一点——写不出ListView就不睡觉了！

## 学点AS技巧(视图xml中快速生成代码)

LinearLayout中：`or` => android:orientation

这个属性是设置线性布局的方向，一般是vertical(从上往下)

`<Lis` => 自动生成ListView组件

所有自动生成组件的代码都是通过左尖括号+组件名

<i class=“fa fa-hashtag"></i>
给ListView添加子布局文件row.xml

## 淘宝订单详情页面(flex-grow: 1)

![list_view](list_view.png)

<i class="fa fa-hashtag"></i>
listView每行只有两个元素，如何才能两个TextView左对齐右对齐

最佳实践是中间填一个高度为1的空view，设置一个类似flex-grow: 1的属性填充剩余空间

中间放一个<var class="mark">layout_weight="1"</var>的空的View组件填充剩余空间

```xml
<!-- 塞到两个TextView中间的组件 -->
<View
  android:layout_width="0dp"
  android:layout_height="1px"
  android:layout_weight="1" />
```

<!-- tabs:start -->

#### **两个布局文件**

以下的xml代码省略了组件的部分属性

> layout/items_container.xml

```xml
<LinearLayout>

  <ListView
    android:id="@+id/list_view"/>

</LinearLayout>
```

> layout/item_detail.xml

```xml
<LinearLayout>

  <!-- 布局参考：淘宝-订单详情页面 -->
  <TextView
    android:id="@+id/detail_key"/>

  <!-- layout_weight=1让容器占据剩余宽度 -->
  <!-- 类似css的flex-grow: 1 -->
  <View
    android:layout_width="0dp"
    android:layout_height="1px"
    android:layout_weight="1" />

  <TextView
    android:id="@+id/detail_value"/>

</LinearLayout>
```

#### **DetailAdapter.java**

```java
  private LayoutInflater inflater;

  public CurrencyAdapter(Context context, List<HashMap<String, String>> currencies) {
    // 构造方法会隐式地调用super。个别需要super的构造方法Overloading时才需要写super
    this.currencies = currencies;
    this.inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
  }

  public DetailAdapter(Context context, ArrayList<ArrayList<String>> data) {
    this.data = data;
    this.inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
  }

  @Override
  public View getView(int index, View convertView, ViewGroup parent) {
    if (convertView == null) {
      convertView = inflater.inflate(R.layout.item_detail, parent, false);
    }
    TextView key = convertView.findViewById(R.id.detail_key);
    TextView value = convertView.findViewById(R.id.detail_value);
    ArrayList<String> detail = data.get(index);
    key.setText(detail.get(0));
    value.setText(detail.get(1));

    return convertView;
  }
```

#### **detailFragment.java**

```java
  private CurrencyAdapter adapter;

  @Nullable
  @Override
  public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
    // return super.onCreateView(inflater, container, savedInstanceState);
    return inflater.inflate(R.layout.items_container, container, false);
  }

  @Override
  public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
    Activity activity = getActivity();
    assert activity != null;
    Context context = activity.getApplicationContext();
    List<HashMap<String, String>> currencies = new ArrayList<>();
    adapter = new CurrencyAdapter(context, currencies);
    ListView listView = Objects.requireNonNull(getView()).findViewById(R.id.list_view);
    listView.setAdapter(adapter);

    // 省略获取接口数据的代码，在response回调中adapter.updateData或listView.setAdapter即可
  }
```

<!-- tabs:end -->

## include layout模板继承
