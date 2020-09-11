# [RefCell实现lazy_static](/2020/09/refcell_impl_lazy_static.md)

我认为这是一道很好的面试题: 如何实现std::lazy::OnceCell或lazy_static?

由于OnceCell已加入std，可以打开以下路径的源文件去阅读SyncOnceCell的源码

> ~/.rustup/toolchains/nightly-x86_64-apple-darwin/lib/rustlib/src/rust/library/std/src/lazy.rs

## sync和unsync的OnceCell

看使用场景，只要用到了static关键字那就只能用多线程安全的OnceCell

不管你的static是在main函数内或者外定义的，只要是static的编译后就存在static区需要考虑多线程的数据竞争

只有用let绑定的变量才能用unsync::OnceCell

|`!Sync` types         | Access Mode            | Drawbacks(缺点)                                |
|----------------------|------------------------|-----------------------------------------------|
|`Cell<T>`             | `T`                    | requires `T: Copy` for `get`                  |
|`RefCell<T>`          | `RefMut<T>` / `Ref<T>` | may panic at runtime                          |
|`unsync::OnceCell<T>` | `&T`                   | assignable only once                          |

|`Sync` types          | Access Mode            | Drawbacks                                     |
|----------------------|------------------------|-----------------------------------------------|
|`AtomicT`             | `T`                    | works only with certain `Copy` types          |
|`Mutex<T>`            | `MutexGuard<T>`        | may deadlock at runtime, may block the thread |
|`sync::OnceCell<T>`   | `&T`                   | assignable only once, may block the thread    |

## 自己实现OnceCell

```rust
use std::cell::RefCell;
struct MySafeString(RefCell<String>);
unsafe impl Sync for MySafeString {}

// 还可以通过环境变量去实现全局变量
static DB_URL: MySafeString = MySafeString(RefCell::new(String::new()));

fn main() {
    println!("{}", DB_URL.0.borrow());
    // 在项目中可能有需要用dotenv读取配置文件到环境变量中，然后再把环境变量的值经过加工后做成全局变量(其实环境变量已经是全局变量)
    *DB_URL.0.borrow_mut() = "1".to_string();
    assert_eq!("1", *DB_URL.0.borrow());
    println!("{}", DB_URL.0.borrow());
}
```
