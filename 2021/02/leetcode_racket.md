# [leetcode用racket](/2021/02/leetcode_racket.md)

我对racket的第一印象是像lisp/closure那样的S-表达式，后来得知racket是scheme的方言(dialect)，racket is the dialect of scheme

没想到leetcode支持的第一款纯函数式编程语言是racket，隔壁codeforces倒支持Haskell和Ocaml

<i class="fa fa-hashtag"></i>
racket导入标准库的图形包，并绘制一面五星红旗

```
#lang racket
(require 2htdp/image)
(overlay (star 15 "solid" "yellow") (rectangle 100 61.8 "solid" "red"))
; 绘制一个菱形
(rhombus 45 60 "solid" "cyan")
```

scheme/racket的注释符号是分号，DrRacket的方向键上⬆并不能复制上一次输入的命令，要用<kbd>esc</kbd>+<kbd>p</kbd>

## racket数值运算

quotient和reminder这两operator合起来类似Python的divrem函数，`(quotient 10 3) = 3`取商

## list in racket

```
> (define a '(1, 1+4i, #f))
> (list? a)
#t
> ;car取list的第一项
(car a)
1
> ; cdr取list除第一项外的剩余项
(cdr a)
'(,1+4i ,#f)
```

cadr取list第二项

caddr取list第三项

racket没有while/loop语句，想实现流程控制就只能靠 if+递归

例如获取数组长度就得依靠 cdr和递归实现遍历

```
(define (len _list)
  (if (empty? _list)
      0
      (+ 1 (len (cdr _list)))
    )
  )
(require racket/trace)
(trace len)
(len '(1,2,3))
```

当我写出了求数组长度的racket函数后，那么求和也不难了，现在可以试试做道leetcode简单题

我选择挑战一道比较简单的`xor_operation_in_an_array`这题

仿照racket/scheme对数组求和的函数，很容易就写出了解答

```
(define/contract (xor-operation n start)
  (-> exact-integer? exact-integer? exact-integer?)
  (if
   (= n 1)
   start
   (bitwise-xor
    start
    (xor-operation (sub1 n) (+ start 2))
    )
   )
  )
```

总的来说racket写题解只能递归还是挺费脑子的，我个人从审美上也不太喜欢S-表达式(尤其是嵌套很多层括号时)，而且也没有rustfmt那样格式化代码的工具，
也不能tfn快速生成可执行的单元测试函数，我还是回归Rust/C++刷题算了

(尤其是那个list递归替换和求S-表达式的函数，我难以理解，求最大深度函数，if调过来写就不行)
