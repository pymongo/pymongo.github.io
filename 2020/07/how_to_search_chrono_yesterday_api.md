# [关键字搜索chrono获取昨天的API](/2020/07/how_to_search_chrono_yesterday_api.md)

不知道为什么Rust的日期时间库要把

获取明日的API命名为`succ`，获取昨日的API叫`pred`

很讨厌这种令人费解的pred, succ缩写，导致我花了很多时间才找到获取昨日的API

而且文档中对pred API的描述是: Makes a new Date for the prior date.

所以在文档中搜索previous、yesterday、last day等关键字都无法检索到pred API

找到chrono pred API的艰难过程值得记录一下，分享下我是如何逐步缩小搜索范围最终找到想要的API

## 发现有succ这个API

1. Google: rust chrono yesterday
2. [How to get a duration of 1 day with Rust chrono? - Stack Overflow](https://stackoverflow.com/questions/59662500/how-to-get-a-duration-of-1-day-with-rust-chrono)

接下来有两个思路，一是在idea里面找到succ的源码，昨日和明日的API一般是挨着一起的

我接下来继续用谷歌搜索找到答案:

1. Google: rust chrono last friday
2. [chrono::Weekday - Rust - Docs.rs](https://docs.rs/chrono/0.3.0/chrono/enum.Weekday.html)
3. 在chrono::Weekday的文档内，往下滚动就能看到impl部分，impl的第二个API就是pred

描述是: The previous day in the week.

Weekday的pred描述是previous day，而chrono::Date的pred的描述是prior date

查询文档发现其实还有第三种思路，全局按`previous day`关键字搜索代码的docstring，也能找到pred API

---

如何pred可以理解成previous day的缩写

那么succ如何理解成明天?

单词学习:

succeeding: 后一，后继地，接替地

prior: 优先，在前

像Ruby(Rails环境)一样用Date.yesterday或Date.tomorrow多好，没有单词缩写也没有歧义
