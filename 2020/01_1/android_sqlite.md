# [安卓读写SQLite数据库](/2020/01_1/android_sqlite.md)

<i class="fa fa-hashtag"></i>
该用哪个API？android.database.sqlite还是androidx.room？

> android.database.sqlite的优缺点

- API较底层，代码里大
- 没有SQL语句验证，也没有SQL注入的检查 
- 需要大量模板代码(boilerplate code)去转换SQL语句和Java对象
- 没有数据库迁移(Room真👍，支持迁移)，更改表结构会带来很大麻烦



<i class="fa fa-hashtag"></i>
Gradle添加Room的API库的依赖

普通JDK：String output = DigestUtils.md5Hex(inputString);


安卓JDK：String output = String(Hex.encodeHex(DigestUtils.md5(inputString)));

```
def room_version = "2.2.3"
implementation "androidx.room:room-runtime:$room_version"
annotationProcessor "androidx.room:room-compiler:$room_version"
testImplementation "androidx.room:room-testing:$room_version"
```

<!-- tabs:start -->

#### **AppDatabase.java**

```java
// utils/AppDatabase.java
// TODO Singleton pattern
@Database(entities = {Market.class}, version = 1)
public abstract class AppDatabase extends RoomDatabase {
  public abstract MarketDao marketDao();
}
```

#### **MainActivity.java**

!> 在主线程同步执行SQL语句会报错，需要加个参数允许(不是最佳实践)

```java
// TODO db实例变量应该通过AppDatabase的单例模式去存储
public static AppDatabase db;
private static void initDatabase(Context context) {
  // Cannot access database on the main thread since it may potentially lock the UI for a long period of time.
  db = Room.databaseBuilder(context, AppDatabase.class, "cadae.db")
    .allowMainThreadQueries() // FIXME 主线程同步执行SQL可能耗时很久卡线程
    .build();
}

protected void onCreate(Bundle savedInstanceState) {
  MainActivity.initDatabase(getApplicationContext());
}
```

#### **Market.java**

```java
// models/Market.java
@Entity(tableName = "markets")
public class Market {
  @PrimaryKey(autoGenerate = true)
  public int id;
  @ColumnInfo(name = "market")
  public String market;

  public Market(String market) {
    this.market = market;
  }
}
```

#### **MarketDao.java**

```java
// models/MarketDao.java
@Dao // DAO design pattern: Data Access Object
public interface MarketDao {
  @Insert
  public void create(Market market);

  @Query("SELECT * FROM markets LIMIT 1")
  public Market first();
}
```

<!-- tabs:end -->

<i class="fa fa-hashtag"></i>
TODO

增加异步执行SQL的实现代码

<i class="fa fa-hashtag"></i>
参考文章

[Save data using SQLite](https://developer.android.com/training/data-storage/sqlite)

## TODO Room Database 迁移