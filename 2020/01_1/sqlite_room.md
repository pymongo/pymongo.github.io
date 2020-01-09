# [使用Room读写SQLite](/2020/01_1/sqlite_room.md)

验证代码成功修改了安卓的SQLite，我认为有几个方法：打log、安卓自带的SQLite Viewer、

adb连上SQLite、安卓端或PC端的SQlite可视化工具等等，我还是喜欢打log

<i class="fa fa-hashtag"></i>
去掉log中无用的前缀，提高信噪比

如`2020-01-08 20:18:34.040 20145-23939/com.monitor.exchange`这种前缀不该出现在log中

[Hide datetime in android log](https://stackoverflow.com/questions/18125257/how-to-show-only-message-from-log-hide-time-pid-etc-in-android-studio)

<i class="fa fa-hashtag"></i>
添加Room的API库

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