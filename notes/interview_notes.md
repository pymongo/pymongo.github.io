# [技术面试复习大纲](/2020/05/interview_notes.md)

以3个主要的方向(算法、编程范式、系统设计)去准备技术面试

学有余力的话，还可以学下底层理论(按列遍历二维数组不能命中CPU三级缓存)

## System Design

### 如何防止用户重复点击导致表单重复提交

category: 分布式、防重入、幂等性(Idempotence)

#### 为什么需要防重入

假如售票网站只有一张火车票，结果用户鼠标重复点击买到了10张票

又例如微博点赞系统、淘宝好评系统，不希望一个用户就能刷好多个好评

#### 前端应对措施

用户点击按钮发送表单请求后，将表单按钮「禁用」掉Vue或安卓的按钮都用disable(属性)

等到网络请求(一般都是异步的)的response回调中将按钮恢复

以js的fetch API为例，调用fetch()的上一行禁用按钮，在`.then(response`时恢复

```js
button.disabled = true;
return new Promise((resolve, reject) => {
    fetch(url, {
        body: "user_id=1",
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
    }).then(response => {
        console.info(response)
        if (response.status !== 200) {
            console.error(`HTTP status_code(${response.status}) != 200`)
            reject(new Error(`HTTP status_code(${response.status}) != 200`))
        }
        response.json().then(data => {
            console.log(`== [on response]${url}`)
            console.info(data)
            button.disabled = false;
            resolve(data)
        })
    }).catch((e) => {
        console.error(e)
        reject(e)
    })
})
```

这样处理之后，每个client在同一时间只能发起一个请求

但是仅靠前端作防止重复提交的处理是不够的，防不了使用爬虫或其他HTTP客户端发起的请求

#### 后端应对

所谓幂等性，在编程领域指的是`对同一个系统，使用同样的条件，一次请求和重复的多次请求对系统资源的影响是一致的`

方法一：请求携带token参数

每一次操作生成一个唯一性的token，一个token在操作的每一个阶段只有一次执行权

以电商应用为例，用户购买商品可分为 订单表创建一条订单记录、商品的库存减少、锁定优惠券、支付 等等

例如用户下单后因余额不足而支付失败，用户请求的token就卡在了支付的阶段，再次发起请求时不会走前面的流程，只会从支付开始走

具体的代码实现可以使用状态机或状态转移图的编程范式

方法二：数据库，一张临时性的去重表，用户ID和订单ID字段是unique的，每次下单请求都往去重表写一次，支付/库存减少的操作就只看去重表的数据，不看请求的数据

方法三：共享变量/数据库的相关加锁，让相同的请求必须以严格的先后顺序逐个处理

## 编程范式

### Actor

<i class="fa fa-hashtag"></i>
Q: 什么是Actor System

最早起源于Erlang，是一种类似线程的数据结构。著名的Actor框架有Java的Akka。

无论是Akka、Rust的Actix还是Go的isrs，用Akka实现的Web框架几乎都是性能最好的框架，例如actix-web是Rust性能最好的Web框架。

<i class="fa fa-hashtag"></i>
Q: 比Spring Boot性能更好的框架?

Akka(Actor)

### 异步和同步

<i class="fa fa-hashtag"></i>
Q: 为什么要异步编程

能充分利用CPU的空闲时钟周期，性能更好

<i class="fa fa-hashtag"></i>
await的作用

异步变同步，用同步的思维写异步编程的代码

futures do nothing unless polled or await

### 类型较丰富语言和类型不丰富语言

自从Go/Rust做到了编译语言的自动类型推断以后，而且Rust/Java也有REPL环境，

我认为不能局限于 动态/静态 和 弱类型/强类型 语言这两个维度去看待编程语言

我个人认为更可靠可以分为 类型较丰富语言 和 类型不丰富语言

例如Python

例如Java，有符号的无符号的整数都叫int或long，在python里就只是一个Number

C/C+还将整形

但是在Rust/Go/+中，整数还分u8、u32......

---

## Rust

### Rust答疑

Rust 1.44更新日志中有这么一段：

[Special cased vec![] to map directly to Vec::new(). This allows vec![] to be able to be used in const contexts.](https://github.com/rust-lang/rust/pull/70632)

PR description中有大量的`IR`缩写，请问IR指的是什么？

---

## ByteDance

### 算法题侧重点

字节跳动(bytedance)编程题/算法题的考核重点

1. Easy或Medium难度就够了

2. 树/图这种考的少，数组/dp/双指针/逻辑(智商题)这种可能考的比较多

以下是bytedance某员工对我简历版本(c6c730bdf714fd544af589580ec3e0c25c13f470)的review建议

### 博客和leetcode要不要写

简历里千万不要出现刷题的经历或leetcode项目

个人博客算是亮点，放到联系方式里，后者在自我介绍中加上，不要单独写成一个项目

### 开源项目参与

如果开源项目投入度/参与度不高，只是一些边边角角的PR，可以穿插进项目经历中，或者放在简历最后独立写

---

## 多线程

### Atomic原子序

TODO

### 全局变量和单例模式

### 多线程的单例模式

---

## 内存管理

### 内存最小单位是Byte

32位/64位的CPU寄存器的可能最小单位是byte，所以c/c++/rust的size_of API返回的单位都是Byte，即便是bool类型也是占1byte的内存。

MySQL虽有Bit的数据类型，但是Bit类型至少也要占1Byte的内存，而且反序列化麻烦，还不如用u8类型

C51单片机有Bit类型，但由于51单片机(8位机)的寄存器的也是8bit的，所以我推测C51的Bit类型最低也占1Byte的内存

### 智能指针

在C++11中，会有三种智能指针

- unique_ptr: 独占内存，不共享。在Rust中是: std::boxed::Box
- shared_ptr: 以引用计数的方式共享内存。在Rust中是: std::rc::Rc
- weak_ptr: 不以引用计数的方式共享内存。在Rust中是: std::rc::Weak

---

## C/C++

### 虚函数(实现多态)

TODO

### 虚析构函数

TODO

---

## Rust

### inline函数

FFI编程相关，C语言宏在 Rust 中会实现为 #[inline] 函数

### cargo工具链

#### cargo tree解决第三方库版本问题

```
root@remote-server:~/app# cargo tree -d | grep md-5
└── md-5 v0.9.0
└── md-5 v0.9.0 (*)
```

#### cargo expand(宏展开)

推荐在一个子文件夹内(就一个lib.rs)使用cargo expand，否则将项目的所有rust源文件都展开的话，输出结果长得没法看完

#### cargo alias

在项目根目录新建一个文件 .cargo/config 就能实现类似npm run scripts的效果

IDEA运行同一个文件的多个单元测试函数时，默认是多线程的，建议加上--test-threads=1参数避免单元测试之间的数据竞争

```
[alias]
myt = "test -- --test-threads=1 --show-output --color always"
matcher_helper_test = "test --test matcher_helper_test -- --test-threads=1 --show-output --color always"
run_production = "cargo run --release"
```

运行某个单元测试文件中的某个测试函数

> cargo test --test filename function_name -- --test-threads=1 --show-output

---

## Java

### 为什么需要Interface

1. (Java特有)实现code block传参，代码块或函数指针做完函数的入参或返回值。应用：不同Activity和Fragment页面对同一个WebSocket连接返回的数据，
需要做不同的处理会在onResume时产生不同的处理，例如首页只需要监听Ws频道1。实现代码是在Activity的onResume回调时定义当前页面的对Ws的onResponse的回调方法
离开页面时将onResponse回调设为null，等待新的页面重新设定Ws的onResponse

```java
  @Override
  public void onResume() {
    super.onResume();
    WebSocketConnection.getInstance().connect(message -> {
      // ...
    });
    WebSocketConnection.getInstance().subscribe(channel);
  }
```

```java
public final class WebSocket extends WebSocketClient {
  private static WebSocket instance;

  public interface onMessageListener {
    void onMessageCallback(String message);
  }

  /**
   * BottomNavigationView切换Fragment时流程有点「特殊」，例如页面1->页面2时流程如下
   * 1. 页面2.onCreateView
   * 2. 页面2.onResume
   * 3. 页面1.onPause
   * 所以不能在页面1的onPause中清空回调监听，不然会把页面2辛辛苦苦设好的listener清掉
   * 首页三个Tab页都是共用market_list频道，不需要在Fragment切换时取消订阅
   * 只需在离开MainActivity时取消订阅所有频道即可
   */
  public void setListener(onMessageListener listener) {
    this.listener = listener;
  }

  private onMessageListener listener;

  public static onMessageListener emptyCallback = message -> {};

  public static WebSocket getInstance() {
    if (instance == null) {
      try {
        instance = new WebSocket(new URI(Urls.WEBSOCKET_SERVER));
        // 每隔5秒向服务器发送一次ping消息，如果收不到pong则说明已掉线
        instance.setConnectionLostTimeout(0); // 永不掉线
      } catch (URISyntaxException e) {
        Log.e(TAG, "WebSocket getInstance: " + Log.getStackTraceString(e));
      }
    }
    return instance;
  }

  private WebSocket(URI serverUri) {
    super(serverUri);
  }

  @Override
  public void onMessage(ByteBuffer bytes) {
    Log.i(TAG, "onMessage: " + gzipDecompress(bytes.array()));
    listener.onMessageCallback(gzipDecompress(bytes.array()));
  }
}
```

2. (可能是Rust特有)泛型入参

3. 多继承/多范式

### 单例模式

懒汉、饿汉、双重校验锁、静态内部类

延迟加载问题、多线程的单例模式问题

Java把其它语言用指针/闭包就能做到的事情 抽象成更复杂的「设计模式」...

https://www.zhihu.com/question/391694703/answer/1207383438

你不会真的认为Java中那中全是boilerplate code的单例模式是什么值得借鉴的语言精华吧，

那不过就是成功克服了别的语言中不存在的困难而已。

还有很多人，一个例对象的创建搞的那么复杂，各种锁，double check。那如果真的有这种需求，

是不是最起码得保证单例对象的各种操作也是线程安全的，不然也没法用在多线程的场景，有什么意义？

那随便调用一下一个方法，开销就比创建对象大了，搞什么double check来优化性能的意义何在？

说白了还是那些低等的语言太惯着使用者了，随便就能让你写出线程不安全的代码。

如果你觉得在Rust里创建一个单例对象很复杂，那是因为它本来就很复杂，其他语言中忽略的潜在错误，你都得显式地考虑，而我也不觉得这是Rust的缺点。

原生方法：全局函数不就可以做到了？一个atomic bool记录是否第一次初始化，如果是，就执行特定逻辑

---

## MySQL

### 数据库连接池使用SELECT 1保持连接

我发现diesel::r2d2的查询日志中有大量的SELECT 1语句，

SELECT 1是用来保持数据库连接的吗？

获取连接和释放连接心跳检测：建议全部关闭，否则每个数据库访问指令会对数据库生产额外的两条心跳检测的指令，增加数据库的负载

连接有效性的检查改用后台空闲连接检查

### \[性能调优]确定只返回一条数据加LIMIT 1

你知道只有一条结果，但数据库并不知道，LIMIT 1让数据库主动停止游标移动

### 索引

#### 布尔值不用索引

经验上，能过滤80%数据时就可以使用索引。对于订单状态，如果状态值很少，不宜使用索引，如果状态值很多，能够过滤大量数据，则应该建立索引。

性别只有男，女，每次过滤掉的数据很少，不宜使用索引。

#### 不要过度索引

加索引会影响「写」的性能，索引多了mysql也可能不知道第一时间选用哪个索引于是去遍历索引方案，导致读的性能也变慢

#### NULL值影响索引

Nullable的列的单列索引可能不生效

---

## 算法

## 数据结构设计题

设计一个twosum类，拥有add和find方法，现在有两种实现方案：

A: add is O(N), find is O(1)
B: add is O(logn), find is O(logn)

这时候必须跟面试官沟通，请问add和find方法的出现次数是多少？如果是add调用次数更多就用B方案

## binary search的缺点

bsearch只是发现需要插入的位置在哪，logn，插入的过程又要O(n)

所以有序数组用插入排序更好，数组末尾补上一个0，然后挪动数组

这里能不能用链表？->插入也是需要O(1*n)

~~BST平衡二叉树~~

~~并不是所有二叉树的时间复杂度都是logn，只有平衡二叉树BST才是~~

BST=Binary Search Tree=左<中<右的二叉树

## PriorityQueue(heap)

列举所有方案：n^3, 方案总数：n^2批量数

时间复杂度与for循环层数无关，例如2个for循环，如果外层和内层的最坏情况不会同时出现，那么时间复杂度小于n^2

图：for 每个点再for每个边，时间复杂度是m个点+2n边，每条边被访问两次，时间复杂度不是n^2

## 数据库

### 分库分表

### FOR UPDATE悲观锁

TODO

---

操作系统
比如说：操作系统如何实现“函数调用”（包括：参数传递 ＆ 返回值传递）
比如说：进程的内存布局
比如说：“堆内存”与“栈内存”的差异
比如说：虚拟内存的原理
比如说：各种缓存机制
比如说：并发相关的一些机制
......

编程语言的底层
比如说：当你用的编程语言支持“运行时多态”，你需要知道编译器/解释器是如何做到的。
比如说：当你用的编程语言支持“异常机制”，你需要知道“异常抛出 ＆ 异常捕获”的原理
比如说：当你用的编程语言支持“GC”（垃圾回收），你需要懂 GC 的原理
比如说：当你用的编程语言支持“GP”（泛型编程，比如 C++ 的 template），你需要支持编译器如何实现 GP
......

数据库的底层
（如果你开发的软件涉及数据库，这方面也需要懂一些）
比如说：查询语句的不同学法，性能差异如何（单单这条，就足以写一本书）
比如说：索引的类型及原理（包括：不同类型业务数据，如何影响索引的性能）
比如说：事务的原理，事务如何达到 ACID（很多程序员连事务的 ACID 都没听说过）
比如说：表结构的设计，有啥讲究
......

网络的底层
（如果你开发的软件涉及网络，这方面也需要懂一些）
比如说：OSI 7层模型
比如说：你用到的网络协议的规格
比如说：分布式的软件系统，会碰到哪些【根本性的困难】
比如说：CAP 定理
......

## 其它

### 相比Ruby，Rust的优势是

1. 没有不能编译的第三方库，Ruby的话一言难尽，例如passgen编译失败、某些依赖llvm编译的库也会失败等等
    Rust的很多第三方库的安装不依赖于各种系统包例如libxxx、llvm等等
2. Rust的第三方库不依赖Rustc的版本，不像Ruby的httparty，
    在Ruby2.6.1版本上能发www-form的POST请求，
    在Ruby2.5.0版本发送的www-form的POST请求是错误的(非标准格式)