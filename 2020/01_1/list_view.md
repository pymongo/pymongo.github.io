# [Android - ListView](/2020/01_1/list_view.md)

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
    android:id="@+id/item_key"/>

  <!-- layout_weight=1让容器占据剩余宽度 -->
  <!-- 类似css的flex-grow: 1 -->
  <View
    android:layout_width="0dp"
    android:layout_height="1px"
    android:layout_weight="1" />

  <TextView
    android:id="@+id/item_value"/>

</LinearLayout>
```

#### **Adapter**

```java
  private LayoutInflater inflater;

  public CurrencyAdapter(Context context, List<HashMap<String, String>> currencies) {
    // 构造方法会隐式地调用super。个别需要super的构造方法Overloading时才需要写super
    this.currencies = currencies;
    this.inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
  }

  // ...

  public void updateCurrencies(List<HashMap<String, String>> currencies) {
    this.currencies = currencies;
    notifyDataSetChanged();
  }

  @Override
  public View getView(int index, View convertView, ViewGroup parent) {
    if (convertView == null) {
      convertView = inflater.inflate(R.layout.listitem_currency, parent, false);
    }

    ImageView currencyIcon = convertView.findViewById(R.id.currency_icon);
    TextView currencyID = convertView.findViewById(R.id.currency_id);
    Map<String, String> currency = currencies.get(index);
    currencyCode.setText(currency.get("code"));
    currencyID.setText(currency.get("id"));

    return convertView;
  }
```

#### **Adapter**

<!-- tabs:end -->
