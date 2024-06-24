# [用clear别用=[]](/2024/06/python_use_clear.md)

在调试一个py静态变量内存指针地址为什么发生变化的时候，同事无人能答，gpt给我解惑了

```python
dydxv4.pos=[]
for d in r['positions']:
    dydxv4.pos.append(pos_cvt(d))
return dydxv4.pos
```

`dydxv4.pos=[]`会重新malloc内存分配，改成 `dydxv4.pos.clear()` 这样函数返回的静态变量地址就不变了
