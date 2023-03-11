# [split cmd with space](/2023/03/shlex.split-cmd_args_with_space.md)

subprocess.Popen 第一个参数要么 str 类型的 cmd 要么 `List[str]`

subprocess.Popen('echo "I love you"') 会报错 `echo "I love you"`

我开始想法是，Python 的命令行参数解析相关的标准库都好几个了 getopt, optparse, fire 等等，应该在标准库能找到吧

我反复改了多个搜索关键词才找到标准库想要的方法 [shlex.split()](https://stackoverflow.com/questions/11846232/handling-directories-with-spaces-python-subprocess-call)

迭代/修改好久之后，最终我给 Google 的并能找到理想的答案的 prompt 是

> subprocess cmd parse with space

## AI prompt

最近有个新职位叫 AI prompt engineer 专指给 chatGPT/stableDiffusion 等 AI 大模型准确提示词快速找到想要信息

AI 作画第一次输入提示词生成的图片，AI 会乱画，需要给 AI 提示你需要怎样的艺术风格，例如毕加索画风

不光要准确的多个 prompt 还要一些 negative prompt 告诉 AI 你不希望看到什么

给 Google prompt 去找到 shlex.split 是如此之低效，那么换 chatGPT 试试

```
How to split/parse command with white space in these Python code

subprocess.Popen('echo "a cat"')
```

结果一次就得到结果，果然 chatGPT 也能当一个搜索引擎且更容易理解使用者的需求
