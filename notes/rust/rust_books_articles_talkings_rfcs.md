# 我读过的Rust相关的books/articles/rfc/issues/PR/talking/podcast

超喜欢`rustup doc --book`这个命令直接在浏览器打开the book书籍进行阅读，全套书籍目录请直接rustup doc或rustup doc --help

在飞机上或火车上，没网的环境下静下心来好好看Rust的这些书籍，不仅有Rust官方出品的10来本高质量书籍，还有尽情阅读标准库文档和源码

## 看完的(不完全统计)

- [article: Dining Philosophers(Mutex解哲学家进餐问题) - 1.2.0 book](https://doc.rust-lang.org/1.2.0/book/dining-philosophers.html)
- [video_list: Rust Programming Tutorials by dcode](https://www.youtube.com/playlist?list=PLVvjrrRCBy2JSHf9tGxGKJ-bYAN_uDCUL)
- [source: reqwest/examples/json_typed.rs](https://github.com/seanmonstar/reqwest/blob/master/examples/json_typed.rs)
- [article: 包和模块 - rustprimer(感谢rust.cc社区编写的中文教程书籍)](https://rustcc.gitbooks.io/rustprimer/content/module/module.html)
- [video: Learning Rust: Memory, Ownership and Borrowing](https://www.youtube.com/watch?v=8M0QfLUDaaA&list=LLFLN2ZAPopjz2zM-FomwnkQ&index=2&t=8s)
- [book: Rust编程之道第一版](https://github.com/ZhangHanDong/tao-of-rust-codes)
- [article: Build Script Examples - The Cargo book](https://doc.rust-lang.org/cargo/reference/build-script-examples.html)

### 看完的async资料

- [talking: Rust's Journey to Async/Await](https://www.youtube.com/watch?v=lJ3NC-R3gSI&t=1700s)
- [article: 刀哥Rust学习笔记3: 有栈协程/无栈协程](https://rustcc.cn/article?id=c0c47719-be7f-4298-ab5a-507cb65f9538)
- [article: 刀哥Rust学习笔记4: async/await](https://rustcc.cn/article?id=495f1e25-2ede-46ec-8c85-8fd823f0a8a9)
- [mdbook: async book](https://rust-lang.github.io/async-book)

## 日常看

- [doc: Trait std::future::Future](https://doc.rust-lang.org/std/future/trait.Future.html)
- [doc: std lib](https://doc.rust-lang.org/std/)
- [mdbook: Reference](https://doc.rust-lang.org/nightly/reference/)
- [mdbook: The Cargo book](https://doc.rust-lang.org/cargol)
- [mdbook: Rust by Example](https://doc.rust-lang.org/rust-by-example/)

## 正在看

- [video_list: 张汉东的Rust实战课 - 极客时间](https://time.geekbang.org/course/intro/100060601)
- [mdbook: the book(The Rust Programming Language)](https://doc.rust-lang.org/book/)
- [mdbook: old book(Include Dining Philosophers)](https://doc.rust-lang.org/1.6.0/book/dining-philosophers.html)
- [video: The Why, What, and How of Pinning in Rust(Jon另一个较老的async视频是基于0.2版带Item的Future，建议先看新的async视频)](https://www.youtube.com/watch?v=DkMwYxfSYNQ)

## 将来看

- [book: Programming Rust 1st edition](https://www.oreilly.com/library/view/programming-rust/9781491927274/)
- [mdbook: Rust Cookbook](https://rust-lang-nursery.github.io/rust-cookbook/)
edition-guide
- [mdbook: Green Threads Explained in 200 Lines of Rust](https://cfsamson.gitbook.io/green-threads-explained-in-200-lines-of-rust/)
- [mdbook: Exploring Async Basics with Rust](https://cfsamson.github.io/book-exploring-async-basics/)
- rustquiz
- cppquiz
- rustling?
- mdbook: Rust死灵书

## Rust实战项目

- [postgres数据库客户端/协议解析器]()

---

## 准备看的其它CS学习资料

- [ ] Advanced Programming in the UNIX Environment
- [ ] 清华大学-操作系统(RISC-V)(2020秋)

---

===

## 没什么营养的英文文章

### Rust in curl with hyper

[curl的HTTP和TLS将用基于Hyper的Rust重写](https://twitter.com/upsuper/status/1314560605622210561)

[RUST IN CURL WITH HYPER](https://daniel.haxx.se/blog/2020/10/09/rust-in-curl-with-hyper/)

文章作者是curl的作者，内容大致是展望libcurl的未来规划(要做成像LLVM一样有个backend，可以自由选择想用的SSL库之类的)以及使用Rust和hyper重写的原因


