# [062 走格子最短路径](/archive/leetcode/062_dp_unique_paths.md)

- [62. Unique Paths](https://leetcode.com/problems/unique-paths/)
- [How to solve Unique path problem](https://hackernoon.com/how-to-solve-unique-path-problem-zj4qt30z3)
- [走格子/棋盘问题 有多少条路径可走](https://blog.csdn.net/yusiguyuan/article/details/12875415)

相似问题：[070 爬楼梯/斐波那契](/archive/leetcode/070_dp_climbing_stairs.md)

![](https://assets.leetcode.com/uploads/2018/10/22/robot_maze.png)

## dp求解

虽然图里面是从左上角到右下角，但是路径总数等效于从左下角走到右上角

由于从左下角到右上角要走最短路径的话，不能走回头路，每次只能向右或向上走

所以递推关系是`f(m,n) = f(m-1,n) + f(m,n-1)`

初始条件是从f(0,0)到f(0,n)、f(0,0)到f(m,0)两条边上的值全为1(因为只能向上或向右走)

遍历方向：从下往上的第二行开始，从左到右地扫，直到填满整个表格的值

## 排列组合求解
