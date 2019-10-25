# 博客各元素CSS测试

## Tags test

asdf

### Referenced Links

[docsify-themeable's][1] [index.html][2].

[1]: https://jhildenbiddle.github.io/docsify-themeable/#/ "title:docsify-themeable"
[2]: https://github.com/jhildenbiddle/docsify-themeable/blob/master/docs/index.html "index.html"

### kbd tag

<kbd>Ctrl</kbd> + <kbd>S</kbd> : Save file

### detail summary tag

<details>
<summary>
summary折叠
</summary>
details被折叠内容...
</details>

---

## block content test

```diff
- docsify don't support But github support
+ this text is highlighted in green
- this text is highlighted in red
```

!> p.tip *em* `code`

?> [docsify的markdown扩充语法](https://docsify.js.org/#/zh-cn/helpers)

> 单行引用

### docsify-plugin-flexible-alerts



> [!NOTE|style:flat]
> 文字部分必须比标题长才能显示An alert of type 'note' using global style 'callout'.

> [!TIP]
> An alert of type 'tip'

> [!TIP|label:haha]
> An alert of type 'tip'

> [!TIP|style:flat|label:untitled|iconVisibility:visible]
> type[tip]style:flat, label:untitled, iconVisibility:visible

> [!WARNING]
> warnning|style:callout 凑下字数凑下字数

> [!WARNING|style:flat]
> warnning|style:flat 凑下字数凑下字数

> [!DANGER]
> DANGER|style:callout 凑下字数凑下字数

> [!DANGER|style:flat]
> DANGER|style:flat 凑下字数凑下字数

### markdown table test

| Tables   | Are           | Cool  |
| ---------|:-------------:| -----:|
| col 1 is | right-aligned | $1600 |
| col 2 is | centered      | $12   |

### docsify-tabs test

<!-- tabs:start -->

#### ** English **

carrot

#### ** Japanese **

人参

#### ** Chinese **

红萝卜

<!-- tabs:end -->

### code block test

`print("单行代码测试")`
```java
class Solution {
    /**
    * @param {int[]} nums
    * @return {int[]}
    */
    public @interface Edible {
        boolean value() default false;
    }
    @Author(first = "Oompah", last = "Loompah")
    Book book = new Book(); 
}
```
