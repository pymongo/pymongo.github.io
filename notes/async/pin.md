# Pin in Future

## Immovable objects

Future的poll方法中，Context参数保存了self指针，类似于结构体的字段B是字段A的指针(自引用?)，

这样才能确保Waker wake的时候能通过该指针找到Future"结构体"。Rust的结构体字段/成员可以被move掉，如果字段A被move掉，字段B就成了野指针，所以要引入Pin确保字段A不被move

```rust
// Immovable objects can store pointers between their fields, e.g
struct MyFut {
    a: i32,
    ptr_to_a: *const i32
}
```

在一个RFC的issue中提出immovable type可以帮助实现intrusive data structures(链式数据结构)

## Pin works in tandem with the !Unpin

Pin<T> immovable if T: !UnPin

只有std::maker::PhantomPinned实现了!Unpin，如果想要让定义的结构体是!Unpin，那就加一个PhantomPinned类型的字段

Unpin means it's OK for this type to be moved even when pinned, so Pin will have no effect on such a type.

简单来说，如果T: Unpin，那么可以拿到Pin内的&mut指针

但是如果T: !Unpin，那么就不能通过safe的代码拿到&mut指针，只要不暴露可变引用，就能避免T被move

如果Future::poll方法内修改了&mut Self，那么async闭包自动生成的结构体中 自引用指向Self字段的指针就会变成悬垂指针

但是有的exector内允许用Unpin type去方便的修改自身，但是切记手写Future代码的poll方法中不要出现mem::swap,replace等操作，

可以局部修改某字段，但不要replace，否则编译器也不会检查出来的悬垂指针UB
