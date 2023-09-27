# [Chain Exception](/2023/04/python_chain_nested_exception.md)

```python
try: 1/0
finally: assert False
```

try..catch 的 catch/finally 代码块中又发生异常，在 Python 称为 **PEP 3134 Exception Chaining**

```
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ZeroDivisionError: division by zero

During handling of the above exception, another exception occurred:

Traceback (most recent call last):
  File "<stdin>", line 2, in <module>
AssertionError
```

> the __context__ attribute for implicitly chained exceptions, the __cause__ attribute for explicitly chained exceptions, and the __traceback__ attribute for the traceback. A new raise ... from statement sets the __cause__ attribute.

## __cause__ 和 __context__ 区别

cause 和 context 都是上一个 Exception 的引用(类比成链表的 next 字段)

PEP 上说 raise..from 是显式的连锁(多层嵌套)异常(`__cause__`)，一般的异常是隐式的连锁嵌套(`__context__`)

对使用者而言二者区别就错误提示文案不同

context 型嵌套/链式异常较为常见，两个异常之间的报错文案为 `During handling of the above exception`

```
>>> raise ZeroDivisionError from TypeError
TypeError

The above exception was the direct cause of the following exception:

Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ZeroDivisionError
```

## ipython 的实现

IPython/core/ultratb.py 相关实现在 def structured_traceback

```python
def get_parts_of_chained_exception(self, evalue):
    def get_chained_exception(exception_value):
        cause = getattr(exception_value, '__cause__', None)
        if cause:
            return cause
        if getattr(exception_value, '__suppress_context__', False):
            return None
        return getattr(exception_value, '__context__', None)
```

该 PEP 说未解决的问题是无法忽略异常上下文，因此 ipython 自己加了个 suppress_context 的属性

```python
if etype is None:
    etype, value, tb = sys.exc_info()
if isinstance(tb, tuple):
    # tb is a tuple if this is a chained exception.
    self.tb = tb[0]
else:
    self.tb = tb
```

sys.exc_info() 返回 traceback tuple 如果是个 chained exception 而不是返回单独一个 traceback object

但 PEP 说了将来 exc_info 会被 deprecated
