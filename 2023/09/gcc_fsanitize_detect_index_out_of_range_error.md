# [-fsanitize 检查越界](/2023/09/gcc_fsanitize_detect_index_out_of_range_error.md)

看到 <https://www.v2ex.com/t/974127> 说本地测试通过的代码在 leetcode 上运行时报错

有人说 leetcode 开了 -fsanitize 于是我让 gpt 给一个 sanitize 能检查出报错的例子

```c
int intarray[5] = {1, 2, 3, 4, 5};
for (int i = 0; i <= 5; i++) {
    printf("%d ", intarray[i]);
}
```

结果 `gcc -fsanitize=address` 也没有编译报错
