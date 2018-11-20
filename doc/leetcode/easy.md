# leetcode简单题/API题

## 9 回文数

条件反射般想到用String::reverse

```python
quotient, remainder = divmod(x, 10)
while x > 0:
    x, r = divmod(x, 10)
    arr.append(r)
```

## 28 查找子串在字符串中出现位置

实现下C语言的strStr函数

## 43/415 字符串整数相乘/相加

## 50 计算 x 的 n 次幂函数

## 69/367 平方根

一个计算平方根， 一个判断平方根是不是整数

[维基百科:How to compute sqrt](https://en.wikipedia.org/wiki/Methods_of_computing_square_roots)

## 224 实现计算器(eval)

## 231/326/342 判断是否 2/3/4的幂次方

## 867 转置矩阵

```python
import numpy

class Solution:
    # @param {list[list[int]]} A
    # @return {list[list[int]]}
    def transpose(self, A):
        return numpy.matrix(A).transpose().tolist()
```

> 2的幂

```js
return Math.log2(n)%1==0 ? true : false;
```

!> 没3/4的底，需要换底公式，**处理下浮点数运算精度丢失**

```js
if (parseFloat((Math.log(n)/Math.log(3)).toFixed(10))%1 == 0)
    return true;
else
    return false;
```

## [查表法]507 完美数

```java
import java.util.*; 

class Solution {
    public static final Set<Integer> set;
    static {
        // Java9:set = new HashSet<Integer>(Set.of(6,28,496,8128,33550336));
        set = new HashSet<Integer>() {{
            add(6); add(28); add(496); add(8128); add(33550336);
        }};
    }
    public boolean checkPerfectNumber(int num) {
        return Solution.set.contains(num) ? true : false;
    }
}

class SolutionBest {
    public boolean checkPerfectNumber(int num) {
        return num == 6 || num == 28 || num == 496 || num == 8128 || num == 33550336;
    }
}
```

## 46/47/77 全排列/去重排列/组合

```python
from itertools import permutations
return list(permutations(nums, len(nums)))
```

### 47题去重复的全排列，去重的第一反应是set
```python
return list(set(permutations(nums, len(nums))))
```

!> 亲测leetcode解释器含numpy、scipy，没有pandas

### 77题是组合，穷举1-n的组合，长度为k
```python
from itertools import combinations
return list(combinations(range(1,n+1), k))
```