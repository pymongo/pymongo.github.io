# [博客新功能/样式测试](/unarchived/test.md)

## text's style test

~~line-through~~ **strong** *italic* <mark>mark_tag·</mark>

`print("单行代码测试")`

!> p.tip *em* `code`

?> [docsify的markdown扩充语法](https://docsify.js.org/#/zh-cn/helpers)

> 单行引用

### Referenced Links

[docsify-themeable's][1] [index.html][2].

[1]: https://jhildenbiddle.github.io/docsify-themeable/#/ "title:docsify-themeable"
[2]: https://github.com/jhildenbiddle/docsify-themeable/blob/master/docs/index.html "index.html"

### kbd tag

<kbd>Ctrl</kbd> + <kbd>S</kbd> : Save file

## [Markdown task/todo list](https://github.blog/2014-04-28-task-lists-in-all-markdown-documents/)

- [x] Python
- [ ] Rust
- [ ] PHP

## details-summary

<details>
<summary>题目描述</summary>
<blockquote>
<p>给定一个整数数组和一个目标值，找出数组中【和为目标值的两个数】，且元素不能重复</p>
<p></p>
<p>Given nums = [2, 7, 11, 15], target = 9,</p>
<p>Because nums[0] + nums[1] = 2 + 7 = 9,</p>
<p>return [0, 1].</p>
</blockquote>
</details>

## docsify-tabs

<!-- tabs:start -->

#### ** Two-pass Hash Table **

```java
public int[] twoSum(int[] nums, int target) {
    Map<Integer, Integer> map = new HashMap<>();
    for (int i = 0; i < nums.length; i++) {
        map.put(nums[i], i);
    }
    for (int i = 0; i < nums.length; i++) {
        int complement = target - nums[i];
        if (map.containsKey(complement) && map.get(complement) != i) {
            return new int[] { i, map.get(complement) };
        }
    }
    throw new IllegalArgumentException("No two sum solution");
}
```

#### ** One-pass Hash Table **

```java
public int[] twoSum(int[] nums, int target) {
    Map<Integer, Integer> map = new HashMap<>();
    for (int i = 0; i < nums.length; i++) {
        int complement = target - nums[i];
        if (map.containsKey(complement)) {
            return new int[] { map.get(complement), i };
        }
        map.put(nums[i], i);
    }
    throw new IllegalArgumentException("No two sum solution");
}
```

<!-- tabs:end -->

## flexible-alerts

> [!NOTE]
> An alert of type note.

> [!NOTE|style:flat]
> An alert of type 'note.flat'.

> [!TIP]
> An alert of type 'tip'

> [!TIP|style:flat|label:untitled|iconVisibility:visible]
> (style:flat), label:untitled, iconVisibility:visible

> [!WARNING]
> This is a warnning alert!

> [!WARNING|style:flat]
> (style:flat)This is a warnning alert!

> [!DANGER]
> This is a danger alert!

> [!DANGER|style:flat]
> (style:flat)This is a danger alert!


--- 

## diff block test

```diff
- github/vscode support diff block
+ this text is highlighted in green
- this text is highlighted in red
```
