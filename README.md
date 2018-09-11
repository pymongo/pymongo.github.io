文绉绉`test`你好啊

<kbd>kbd</kbd>

# 吴翱翔的博客

自由至上主义者，政治经济业余爱好者，常看政论节目

文章逐渐从各种专栏migrate回来中

<figure>
    <img src="//interactive-examples.mdn.mozilla.net/media/cc0-images/Elephant_In_Silhouette_Closer--660x480.jpg" alt="Elephant at sunset" />
    <figcaption>An elephant at sunset</figcaption>
</figure>

## 临时笔记

## 测试用例

---

!> emoji测试

😉  1 :memo: 2 📝

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