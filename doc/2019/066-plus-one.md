# 066 plus one

一个整数用数组形式存储

数组的每位表示整数的每位 

设计一个函数使 这种数据结构的整数 数值加一  

f([9]) = [1,0] // 带进位功能

注意进位时，要动态扩张数组，Java用System.arraycopy实现

```python
def plusOne(self, nums):
    tmp = ""
    for i in nums:
        tmp += str(i)
    tmp = str(int(tmp)+1)
    nums = []
    for s in tmp:
        nums.append(int(s))
    return nums
```

### java版战胜100%用时小于1ms
```java
class Solution {
    public int[] plusOne(int[] digits) {
        boolean overflow = false;
        int LEN = digits.length;
        for (int i=LEN-1; i>-1; i--) {
            if (digits[i] == 9) {
                digits[i] = 0;
                overflow = true;
            } else {
                digits[i]++;
                overflow = false;
                break;
            }
        }
        if (overflow) {
            // System.arraycopy
            // https://blog.csdn.net/kesalin/article/details/566354
            int[] nums = new int[LEN+1];
            System.arraycopy(digits,0, nums,1,LEN);
            nums[0] = 1;
            return nums;
        }
        return digits;
    }
}
```