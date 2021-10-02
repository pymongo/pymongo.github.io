# [龙书读书笔记 1]()

*Compilers Principles, Techniques, Tools* 也叫编译器龙书，是斯坦福和国内知名高校的编译原理教科书

<dragonbook.stanford.edu>

我将龙书读书笔记和清华编译原理课资料(学堂在线或 b 站之类平台容易找到相关资料)结合起来一起学习

这本书是两个学期的课才能学完，想在一个月内速成绝非容易之事，但事在人为希望能激发学习能力

§ 编译原理课资料我的学习顺序:
- LectureGRA.pdf // 先修课《形式语言与自动机》，课程预备知识
- slide-fla.ppt // 未修过相关课程的参考

注.1: 由于课程预备知识和龙书第二章一样晦涩难懂，只能大致看一遍够用就行等二刷再补课

[编译原理大家是怎么学习的 - v2ex](https://v2ex.com/t/802520#reply69)

## 符号约定

### 字母表

- ∑: 字母表, e.g. `[a-z]`
- 字/word: 由字母表字母组成的字符串，例如 be and b are word of {a,b}
- L/语言: 字母表的若干个字组成的集合
- |w|: 字符串绝对值表示字符串的长度
- ε: 空字符串
- 拼接运算: concat!(x, y)
- 乘积: {0,1}{a,b}={0a,0b,1a,1b}
- 闭包/幂运算: {0,1}^3={0,1}{0,1}{0,1}, 字母表的 0 次幂必然是空字符串
- (*闭包)星/克林闭包: subsets of {0,1}
- (+闭包)正闭包: subsets of {0,1} exclude empty set

### 有限状态机

双圆圈表示终态(accept state), DFA=A=(Q, ∑, δ, q0, F)
- Q: collection of state, Q ≠ empty_set
- ∑: collection of input_symbol, ∑ not empty
- δ(delta): fn(state, input_symbol) -> state
- q0: init state
- F: collection of accept_state

则可以定义 L(语言) 的一个 DFS 为 L(A)

DFA 图上边标记(label)的 0,1 表示 state1->state2 有两条边的省略表示方法

1. DFA: Deterministic Finite Automaton
2. NFA: Nondeterministic Finite Automaton

## 正规语言表示模型

正规表达式、非确定有限状态机、确定有限状态机、带 ε 转移的非确定有限状态机

## context-free grammars

context-free grammars 也叫 BNF (Backus-Naur Form)

假设 -> 是解析的一个分隔符，SVO 是主谓宾

- 上下文无关文法(context-free grammars): S -> 他
- 上下文有关文法: 天V -> 地

所以上下文有关文法既要从 `->` 开始向右边解析，也要向左解析

## analysis and synthesis part

- analysis/front_end: source_code_text -> IR(Intermediate Representation) + symbol table
- synthesis/back_end: IR + symbol table -> target(dylib or executable)

而 analysis 又会有很多 phases

### symbol table

> symbol table stores information about the program is used by **all phases** of the compiler

### 什么是 span

rustc_span::Span 的文档说 span 可能是一个 token 在源码字符串中的 index/position/offset

span in the source input

### compiler phases

compiler front end phases

1. bytes_stream -> lexer -> TokenStream
2. TokenStream -> parser(syntax analyzer) -> AST
3. ASG -> semantic analyzer -> AST with type info // type checking
4. AST -> IR generator -> IR

compiler back end phases by dragon book (LLVM may different)
1. IR -> Machine-Independent Code Optimizer -> IR
2. IR -> Code Generator -> target_machine_code
3. target_machine_code -> Machine-Dependent Code Optimizer -> target_machine_code


e.g. `let position = initial + rate * 60;`

symbol table:
1. position
2. initial
3. rate

convert to tokens `(id:1) (=) (id:2) (+) (id:3) (*) (60)` then convert to AST

AST to IR

```
t1 = int_to_float(60)
t2 = id3 * t1
t3 = id2 * t2
id1 = t3
```

IR optimize

```
t1 = id3 * 60
id1 = id2 + t1
```

IR gen to platform-independence pseudo asm code

```
// LD means load data from memory to register
// F means value type is float
// LD dst:register_2, src:mem_symbol_id_3
LDF R2, id3
MULF dst:R2, lhs:R2, rhs:#60.0
LDF R1, id2
ADDF R1, R1, R2
// register R1 -> mem/reg location id1
STF id1, R1
```

### lexer

TokenStream = `(token_name, Option<attribute_value>)`

书中 Figure 1.7 把 lexer->parser->IR->asm 的过程画的很生动

#### terminals and nonterminals

通常来说 terminal 和 token 是同义词

- terminals/token: lexical elements e.g. keyword, 无法分解为更小的符号
- nonterminals: e.g. expr/stmt represent sequence of terminals
- terminology: 术语

struct token {
    token_name: String,
    token_attr: Option\<PointerToSymbolTable\> // keyword 就没有 token_attr value
}

## misc

- formal parameter: 形参. 两个形参可以指向同一个地址 e.g. strict/pointer_aliasing
- actual parameter: 实参
- three-address code? e.g. `t2 = id3 * t1`
- postfix form of expr e.g. (9 5 -)

### ident and name different

x and y are ident, while x.y is a name, but not an ident















AGG 算子的参数
function_name: max/min/avg/sum/count
function_args: `Vec<expr>`
