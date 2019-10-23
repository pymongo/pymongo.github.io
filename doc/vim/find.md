# vim find/replace

<pre>
查找汇总
f/F&lt;char> - find/previous next char in current line 
*/# - find current word
n/N - find next/previous
N/n - find next in # and ?
</pre>

> [!NOTE]
> 「*」find/highlight current word

n/N - find next/previous

!> 如果用【?/#】搜寻，小写n表示寻找前一个（刚好相反）

## replace

> [!TIP]
> /foo\c # 大小写不敏感查找

> :s/p/h1 # replace next p to h1 in current line

> :%s/p/h1 # replace all in current line

> :%s/p/h1/g # replace all in global

### 局部替换

vision模式选中代码后  :s/原来的/新的字符串

