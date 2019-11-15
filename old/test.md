# 博客各元素CSS测试

## text test

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

#### ** Brute Force **

#### ** Two-pass Hash Table **

#### ** One-pass Hash Table **

<!-- tabs:end -->

<!-- tabs:start -->

#### ** Brute Force **

```java
public int[] twoSum(int[] nums, int target) {
    for (int i = 0; i < nums.length; i++) {
        for (int j = i + 1; j < nums.length; j++) {
            if (nums[j] == target - nums[i]) {
                return new int[] { i, j };
            }
        }
    }
    throw new IllegalArgumentException("No two sum solution");
}
```

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

<script>!function(e){var t=/\b(?:abstract|continue|for|new|switch|assert|default|goto|package|synchronized|boolean|do|if|private|this|break|double|implements|protected|throw|byte|else|import|public|throws|case|enum|instanceof|return|transient|catch|extends|int|short|try|char|final|interface|static|void|class|finally|long|strictfp|volatile|const|float|native|super|while|var|null|exports|module|open|opens|provides|requires|to|transitive|uses|with)\b/,a=/\b[A-Z](?:\w*[a-z]\w*)?\b/;e.languages.java=e.languages.extend("clike",{"class-name":[a,/\b[A-Z]\w*(?=\s+\w+\s*[;,=())])/],keyword:t,function:[e.languages.clike.function,{pattern:/(\:\:)[a-z_]\w*/,lookbehind:!0}],number:/\b0b[01][01_]*L?\b|\b0x[\da-f_]*\.?[\da-f_p+-]+\b|(?:\b\d[\d_]*\.?[\d_]*|\B\.\d[\d_]*)(?:e[+-]?\d[\d_]*)?[dfl]?/i,operator:{pattern:/(^|[^.])(?:<<=?|>>>?=?|->|([-+&|])\2|[?:~]|[-+*/%&|^!=<>]=?)/m,lookbehind:!0}}),e.languages.insertBefore("java","class-name",{annotation:{alias:"punctuation",pattern:/(^|[^.])@\w+/,lookbehind:!0},namespace:{pattern:/(\b(?:exports|import(?:\s+static)?|module|open|opens|package|provides|requires|to|transitive|uses|with)\s+)[a-z]\w*(\.[a-z]\w*)+/,lookbehind:!0,inside:{punctuation:/\./}},generics:{pattern:/<(?:[\w\s,.&?]|<(?:[\w\s,.&?]|<(?:[\w\s,.&?]|<[\w\s,.&?]*>)*>)*>)*>/,inside:{"class-name":a,keyword:t,punctuation:/[<>(),.:]/,operator:/[?&|]/}}})}(Prism);</script>

<script>window.alert("Asdf");console.log(12341241234)</script>