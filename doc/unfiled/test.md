## 标签测试

<details>
<summary>
summary折叠后显示
</summary>
details被折叠内容...
</details>

!> p.tip

?> p.warning

---

<marquee behavior="alternate">marquee tag behavior="alternate"(往回弹),默认是scroll</marquee>

滚动效果的CSS实现: `animation: scroll 7s linear 0s infinite;`

<kbd>Ctrl</kbd> + <kbd>s</kbd> : Save file // kbd tag

<figure>
    <img src="/img/chrome-game-cheat/source.png">
    <figcaption>dino game's source</figcaption>
</figure>

## emoji测试

😉 - :memo: 📝

## 代码块测试

我们需要用 `pip` 安装 `flask`

`print("单行代码测试")`

```java
// comment
public static void main(String[] args) {
    System.out.println("asd");
}
```

<pre class="prettyprint lang-java">
class Solution {
    /**
    * @param {int[]} nums
    * @param {int} target
    * @return {int[]}
    */
    public int[] twoSum(int[] nums, int target) {
        int len = nums.length;
        for (int i=0; i&lt;len; i++) {
            for (int j=i+1; j&lt;len; j++) {
                if (nums[i]+nums[j]==target)
                    return new int[]{i, j};
            }
        }
        return null;
    }
}
</pre>

<script src="/static/js/run.prettify.js"></script>