# [parcelable页面间传递实例对象](/2020/03/parcelable_serializable.md)

Parcelable类似JDK的Serializable接口，用于序列化传输Java实例对象

<!-- tabs:start -->

#### **model**

```java
public static class Product implements Parcelable {
    public String name;
    public boolean is_purchasable;

    /**
     * Parcelable序列化
     */
    Product(Parcel in) {
      name = in.readString();
      is_purchasable = in.readByte() != 0;
    }

    /**
     * Parcelable序列化
     */
    public static final Creator<Product> CREATOR = new Creator<Product>() {
      @Override
      public Product createFromParcel(Parcel in) {
        return new Product(in);
      }

      @Override
      public Product[] newArray(int size) {
        return new Product[size];
      }
    };

    /**
     * Parcelable「反」序列化
     */
    @Override
    public int describeContents() {
      return 0;
    }

    /**
     * Parcelable「反」序列化
     */
    @Override
    public void writeToParcel(Parcel dest, int flags) {
      dest.writeString(name);
//      dest.writeBoolean(is_purchasable);
      // writeBoolean是kotlin特有的方法，用不了
      dest.writeByte((byte) (is_purchasable ? 1 : 0));
    }
  }
```

#### **send parcelable**

```java
holder.itemView.setOnClickListener(v -> {
  Intent intent = new Intent(v.getContext(), CurrencyDetailActivity.class);
  intent.putExtra("product", product);
  v.getContext().startActivity(intent);
});
```

#### **receive parcelable**

```java
if (!getIntent().hasExtra("product")) {
  return;
}
binding.setProduct(getIntent().getParcelableExtra("product"));
```

<!-- tabs:end -->