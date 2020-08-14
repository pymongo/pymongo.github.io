# [直线方程与N皇后问题](/2020/08/n_queens.md)

N皇后的问题在LeetCode上DFS回溯的算法题里不算特别难，相比word_ladder_2代码量也很少

只要代码结果拆分合理，这道题就很难写错，我认为这题可以拆为4个部分:

- 入口函数
- DFS搜索回溯函数(search)
- 判断当前放置皇后的位置是否合法(is_invalid)
- 将正确的皇后位置渲染成棋盘字符串(render_board)，然后在DFS搜索回溯函数里加到答案集内

我认为主要难点就两个 通过什么数据结构存储皇后的位置 和 如何判断某个位置是否合法

既然每行只能有一个皇后，皇后的位置用的是一个一位数组: 数组下标表示皇后的行号，值表示皇后的纵坐标

所以`for x, y in enumerate(queen_cols)`就能得到皇后们的行号和列号

先看一段打印8皇后的简单版代码:

```python
import itertools
for queen_cols in itertools.permutations(range(n)):
    if n == len({queen_cols[i] + i for i in range(n)}) \
         == len({queen_cols[i] - i for i in range(n)}):
        for col in queen_cols:
            s = ['.'] * n
            s[col] = 'Q'
            print(''.join(s))
        print()
```

解释下`len({queen_cols[i] + i for i in range(n)})`这行为什么能验证N皇后

首先`itertools.permutations`保证了每个皇后的列号都不一样

因此只需要判断斜的方向有没有重合

可以将棋盘看做一个初中数学的xoy坐标系，只不过顺时针转动了90度，y轴是横着的

皇后斜的方向就只有两种，左上-右下 和 右上-左下

而xoy坐标系下棋盘的左上-右下的直线方程的斜率为1、右上-左下的斜率为-1

左上-右下的直线方程为: y= x+b => x-y=-b

右上-左下的直线方程为: y=-x+b => x+y=b

所以表达式`queen_cols[i] + i`能得到右上-左下直线方程的「常系数b」

初中数学学过点-斜式方程，通过一点和斜率可以的得到直线方程

所以只要N皇后位置算出的斜率为1和斜率为-1的8条直线的常系数都不一样，则N皇后问题是正确的，否则必有两个皇后在同一条直线上
