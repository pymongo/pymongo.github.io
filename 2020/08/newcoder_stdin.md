# [Rust读牛客网编程题stdin](/2020/08/newcoder_stdin.md)

牛客网编程题的测试用例需要从stdin中读取，跟leetcode不一样

牛客网上从stdin中读数据的常见模式就要么读一行数据，要么读多行数据

所以建议还是准备一个能读取多行数据的模板就够了

```rust
use std::io::BufRead;

const TEST_CASE: [(&[i32], bool); 1] = [
    (&[1, 2, 3], true),
];

fn main() {
    let mut input: Vec<String> = vec![];
    for line in std::io::stdin().lock().lines() {
        if let Ok(str) = line {
            input.push(str);
        }
    }
    let nums: Vec<i32> = input[0]
        .split_whitespace()
        .map(|x| x.parse::<i32>().unwrap())
        .collect();
    dbg!(&nums);
    dbg!(&input);
}
```

如果用的是Python语言则准备下面这个模板

```python
def parse_stdin():
    input_data = []
    for line in sys.stdin.readlines():
        input_data.append(line.rstrip('\n'))
    nums = [int(s) for s in input_data[0].split()]
    print(nums)
    print(input_data)
```

print!("Enter a number: "); std::io::stdout().flush().unwrap();
