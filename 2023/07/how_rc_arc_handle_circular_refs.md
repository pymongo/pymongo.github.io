# [Weak 解决循环引用](/2023/07/how_rc_arc_handle_circular_refs.md)

By using a combination of Arc and Weak, you can break the circular reference

> For example, child nodes in a tree structure could use Weak rather than Arc for their parent node

Rc/Arc 自身无法解决循环引用无法析构的问题，假设有两个节点互相引用，那么无论谁先析构双方引用计数都是从 2 减少为 1 而不会清零导致内存泄漏

所以 leetcode 的二叉树定义就很不合理，存在循环引用的字段必须定义成 Weak 类型

```rust
pub struct TreeNode {
    pub val: i32,
    pub left: Option<Rc<RefCell<TreeNode>>>,
    pub right: Option<Rc<RefCell<TreeNode>>>,
}
```

首先二叉树左右叶子节点肯定不会有多个引用，用 Option Box 足够了，假设还要加一个指向父节点的引用，就用 Weak

```rust
#[derive(serde::Serialize)]
struct Node {
    val: i32,
    left: Option<Box<Node>>,
    right: Option<Box<Node>>,
    parent: Option<std::rc::Weak<Node>>,
}
fn main() {
    let root_node = std::rc::Rc::new_cyclic(|self_| Node {
        val: 0,
        left: Some(Box::new(Node {
            val: 1,
            left: None,
            right: None,
            parent: Some(self_.clone()),
        })),
        right: None,
        parent: None,
    });
    // serde rc feature stack overflow on cyclic https://github.com/serde-rs/serde/issues/2543
    let json = serde_json::to_string(&root_node).unwrap();
    println!("{json}");
}
```

但 Weak 没有 new 方法，创建的时候需要从 Arc 中 downgrade 一个出来

所以 Arc 内部有强弱引用两个 AtomicUsize downgrade 也是克隆但只有弱引用计数加一

---

无 GC 不是吞吐量友好而是延迟友好，所以 Go 有些业务比 Rust 吞吐量好正常，有人评测 Go 写的 js 编译器比 swc 性能好也正常

有 GC 也需要引入弱引用解决循环引用问题例如 Python 标准的 weakref
