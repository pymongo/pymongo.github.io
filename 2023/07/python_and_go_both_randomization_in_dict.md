# [Go map 遍历每次随机](/2023/07/python_and_go_both_randomization_in_dict.md)

最近再将一个 lightgbm 的模型(其实就一个文本文件)推理移植成 Golang SDK，发现同样的 tensor 输入去推理结果推理脚本居然每次推理结果都不一样

跟业务方确认了模型没有随机数的功能后，我只好去看推理脚本

发现了两个问题导致随机:

1. hash(str) 的结果每次运行都不一样
2. map 遍历顺序可能每次运行不一样

```
for i in $(seq 0 4);do python -c "print(hash('foo'))"; done
4689795989476987390
8390453532974412793
6358890978373601347
722556901464223259
-946147316044352463
```

```
Randomization in dictionaries: In Python 3.3 and later versions, dictionaries have randomization enabled by default
# Disable dictionary randomization
os.environ["PYTHONHASHSEED"] = "0"

If you need a consistent iteration order, you can use collections.OrderedDict
```

对于问题一，有些 hash 的算法每次运行都有随机性，go 的 fnv 算法和 python hash() 都有随机性，换成 md5/sha256 去规避

在我的 go 模型推理 sdk 中 hash 的作用仅仅是让 str/int/float 等不同类型归一化成 64bit 数字

md5 hextdigest 是 16 byte 而 lightgbm 推理传入 `List[float64]` 只需要 8byte 所以有所失真

对于问题二，Rust/Go/Python 的 map 均是每次遍历都是随机顺序，Rust/Go 可用 LinkedHashMap 达到 OrderedDict 效果，或者用 pandas.DataFrame 也是有序遍历

或者提前写死个 `List[str]` 作为 order 去遍历 map

最终我 Go sdk 的模型推理数据转换处理过程就是

1. `map[string]interface{}` -> `map[string][float64]`
2. `map[string][float64]` -> `[]float64` 然后传给模型去推理

---

用 gpt 学习 golang 的效率极高，我基本不怎么写 Go 的连结构体定义数据结构初始化都不会就一直问 gpt 几下就搞定了

当我完成 200 多行的 Go SDK 信心满满还能让 gpt 帮我 code review 给出了 7 个修改建议真不错

> Any code review suggestion for below golang code?
