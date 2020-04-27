# [070 爬楼梯/斐波那契](/archive/leetcode/070_dp_climbing_stairs.md)

> 每次你可以爬 1 或 2 个台阶。需要 n 个台阶到达楼顶。  
> 你有多少种不同的方法可以爬到楼顶呢？

这题显然要用动态规划(数学归纳法)求解，类似于给你个mxn的点阵，从左上角走到右上角有几种最短路径的走法

TODO 补充链接

## 解析

!> 第 n 个台阶可以从第 n-1 个台阶走 1 步  
也可以从第 n-2 个台阶一次走 2 步

设走到n-1阶有f(n-1)种，  
那么走到n-1阶后再走一步也是f(n-1)种

!> 递推关系式： f(n) = f(fn-1) + f(n-2)  
显然这是个斐波那契数列(Fibonacci sequence)

## Z变换求解斐波那契

斐波那契数列的通项推导需要「差分方程」、「特征根」、「信号与系统」、「线性代数」等等高数知识

我能理解的最简单的求解方法应该是[Z变换](https://markusthill.github.io/deriving-a-closed-form-solution-of-the-fibonacci-sequence)

## js尾递归

```js
// 斐波那契数列尾递归模板
var fib = (n,a=0,b=1) =>
    n>0 ? fib(n-1,b,a+b) : a;
    
// a: 0=>1, b: 1=>2, n: 0=>1
var climbStairs = (n,a=1,b=2) =>
    n>1 ? climbStairs(n-1,b,a+b) : a;
/* 执行用时：64 ms, 前5% */
```

## js循环版

```js
function f(n) {
    if (n === 1)
        return 1;
    if (n === 2)
        return 2;
    var fn1=2, // f(n-1), init->f(2)
        fn2=1; // f(n-2), init->f(1)
    // for里定义i是局部变量
    for (var i=0,tmp; i<n-3; i++) {
        tmp = fn1;
        fn1 = fn1 + fn2;
        fn2 = tmp;
    }
    return fn1 + fn2;
}
```


### java循环版

```java
// 执行用时：2 ms 战胜 100.00 %
// 用c/c++执行用时小于1ms
if (n == 1)
    return 1;
if (n == 2)
    return 2;
int fn1=2, // f(n-1), init->f(2)
    fn2=1; // f(n-2), init->f(1)
// for里定义i是局部变量
for (int i=0,tmp; i<n-3; i++) {
    tmp = fn1;
    fn1 = fn1 + fn2;
    fn2 = tmp;
}
return fn1 + fn2;
```