# [leetcode上Rust调用C函数](/2020/12/leetcode_rust_call_c_function.md)

以[398. Random Pick Index](https://leetcode.com/problems/random-pick-index/)这题为例，

需求是输入一个整数数组nums和整数target，如果nums中存在多个值等于target的下标i，则随机返回其中一个下标i

虽然leetcode上的Rust环境可以调用第三方库rand的随机数API，但是考虑到codeforces等其它刷题网站上的Rust并不支持第三方库

最佳实践是用Rust调用C语言标准库的rand API，rand()可能是最简单的C语言函数的FFI binding

由于leetcode对随机数判题要求不严格，不需要`srand(time(0));`将rand seed设置成当前时间戳去提高随机性

熟悉Linux C/C++ Dynamic/Static Linking Library(DLL/SLL) 的同学应该不难理解为什么Rust可以直接调用C语言的标准库

```rust
struct RandomPickIndex {
    nums: Vec<i32>,
}

impl RandomPickIndex {
    fn new(nums: Vec<i32>) -> Self {
        Self { nums }
    }

    fn pick(&mut self, target: i32) -> i32 {
        extern "C" {
            fn rand() -> i32;
        }
        let mut count = 0i32;
        let mut ret = 0usize;
        for (i, num) in self.nums.iter().enumerate() {
            if target.ne(num) {
                continue;
            }
            count += 1;
            // 蓄水池抽样: 以1/n的概率更新return_value(留下当前的数据) 或 (n-1)/n不更新return_value(继续用之前的ret的值)
            // n为数据流(online_data,stream_data)中过去数据里值等于target的个数(也就是count变量)
            if unsafe { rand() } % count == 0 {
                ret = i;
            }
        }
        ret as i32
    }
}
```
