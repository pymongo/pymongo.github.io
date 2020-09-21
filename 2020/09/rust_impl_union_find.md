# [Rust实现并查集](/2020/09/rust_impl_union_find.md)

leetcode 204-206周赛连续好几周都考了并查集的题，再不会做就不应该了

好像205周周赛的`min_cost_to_connect_all_points`这题就是经典的并查集应用

平面坐标xoy上有若干个点，你需要找到能连接所有点的最短连边之和

贪心点的思想，两个for循环遍历所有连边扔到小根堆中，尽量多用较短的连边，但是需要通过并查集判断两个点是否已连上

所以Rust的并查集数据结构的实现可以是如下代码:

```rust
struct UnionFind {
    parents: Vec<usize>
}

impl UnionFind {
    fn new(n: usize) -> Self {
        UnionFind { parents: (0..n).collect() }
    }

    fn find_root(&self, node: usize) -> usize {
        let mut curr_node = node;
        let mut curr_parent = self.parents[curr_node];
        while curr_node_parent != curr_node {
            curr_node = curr_parent;
            curr_parent = self.parents[curr_node];
        }
    }
    
    // 如果a和b不相连，则添加一条node_a连向node_b的边
    fn union(&mut self, node_a: usize, node_b: usize) {
        // 路径压缩: 不要直接将b连到a上，而是将b的祖先连向a的祖先，以此压缩路径减少连边
        let root_a = Self::find_root(self, node_a);
        let root_b = Self::find_root(self, node_b);
        if root_a != root_b {
            // 将b的祖先挂载到a的祖先下
            self.parents[root_b] = root_a;
        }
    }
}
```

最后这是我`连接所有点的最短距离`一题的解答

```rust
impl Solution {
    fn min_cost_connect_points(points: Vec<Vec<i32>>) -> i32 {
        let n = points.len();
        let mut edges = Vec::with_capacity(n * (n - 1) / 2);
        for start in 0..n {
            for end in start + 1..n {
                edges.push((
                    (points[start][0] - points[end][0]).abs()
                        + (points[start][1] - points[end][1]).abs(),
                    start,
                    end,
                ));
            }
        }
        edges.sort_unstable();
        let mut total_cost = 0;
        let mut union_find = UnionFind::new(n);
        let mut used_edges = 0;
        for (cost, node_a, node_b) in edges {
            let root_a = union_find.find_root(node_a);
            let root_b = union_find.find_root(node_b);
            if root_a == root_b {
                continue;
            }
            total_cost += cost;
            union_find.parents[root_b] = root_a;
            used_edges += 1;
            if used_edges == n - 1 {
                break;
            }
        }
        return total_cost;
    }
}
```
