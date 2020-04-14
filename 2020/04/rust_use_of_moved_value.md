# [Rust解决use of moved value](/2020/04/rust_use_of_moved_value.md)

看了leetcode第二题上别人的解答之后，自己终于能遍历+构造ListNode了

```rust
// 用于存储生成result链表的节点
let mut current_node : ListNode = ListNode::new(0);
// result链表的头节点，仅仅用于返回值(head_node.next)
let mut head_node : ListNode = ListNode::new(-1);
head_node.next = Some(Box::new(current_node));
// 用于存储当前节点的下一个节点
let mut new_node : ListNode;
let (mut ln1, mut ln2) = (l1, l2);
let mut sum: i32;
// 是否进位
let mut is_carry : bool = false;

loop {
  // 像数字电路datasheet真值表一样...
  match (ln1, ln2) { // 必须要在每个分支都给ln1和ln2复制才能避免moved value的报错
    (Some(node1), Some(node2)) => {
      sum = node1.val + node2.val;
      if sum > 10 {
        is_carry = true;
        sum = sum % 10;
      }
      ln1 = node1.next;
      ln2 = node2.next;
    },
    (Some(node1), None) => {
      sum = node1.val;
      ln1 = node1.next;
      ln2 = None;
    },
    (None, Some(node2)) => {
      sum = node2.val;
      ln1 = None;
      ln2 = node2.next;
    },
    (None, None) => {
      break;
    }
  }
  
  current_node.val += sum;
  if is_carry {
    new_node = ListNode::new(1);
    is_carry = false;
  } else {
    new_node = ListNode::new(0);
  }
  current_node.next = Some(Box::new(new_node));
  current_node = new_node;
} // end of loop
head_node.next
```

上面的代码思路是没错的，就是一直没解决current_node和new_node的use moved value问题

```rust
let mut x = MyStruct{ s: 5u32 };
let y = x; // 这个y在我的代码中相当于第二次循环时的x
x.s = 6;
println!("{}", x.s);
```

指针我用得少不是很熟(谭浩强教科书上的用法就不提了)

而且用了&Option<Box<ListNode>>类型之后赋值变得好麻烦了

但由于唯一解法是指针，这个问题必须啃了

归根到底还是Rust的代码写的太少了，学了10天写的Rust代码也就不到8000行，还需熟练

要是像我现在的安卓水平(40~50万行)，就没那么多疑惑了
