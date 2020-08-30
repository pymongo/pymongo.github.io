# [通过N叉树最大深度一题复习C++](/2020/08/learn_cpp_by_leetcode.md)

最近我通过[leetcode#559 N叉树的最大深度](https://leetcode.com/problems/maximum-depth-of-n-ary-tree/)
一题复习C++

## explicit关键字

为什么要在单个入参的构造方法上加上explicit前缀？

例如有个函数是foo(Node)，有一处调用是foo(1)，

如果不加explicit编译器会调用Node(int)构造函数去将1强制转换为Node实例对象，造成UB

我们更希望的是出现错误的传参时编译器报错而不是将1通过int构造函数转为Node实例对象

## utility库的move

C++和Rust的传参方式类似，也有copy, move, borrow(指针/引用)的概念

但是Rust对传参方式的分类更多，除了C++上述三种外还有take(和move类似)、borrow_mut

每一种传参方式的参数名前面加不加mut又可以细分为两种: mut arg: T 和arg: T

例如N叉树的构造函数中，Clion建议把children入参move掉，避免传参前要将children入参的vector给Copy一份

```cpp
Node(int _val, vector<Node *> _children) {
    this->val = _val;
    this->children = move(_children);
}
```

## 构建测试用例

很可惜C++没有内置单元测试，引入第三方库太麻烦了至今没学会，暂且用main函数里测吧

## 为什么要有引用

网上的说法都是引用是一个实例对象的别名，区别在于传参时会传指针效率高

引用像一个实例对象，可以重载运算符，由于没有=运算符，所以引用是不可变的，不会空指针比较安全

我个人观点引用的作用是解决*&过多导致语义不明，像Rust就没有指针和引用的区分，只有一种

例如我写了一个C++的Decimal类/结构体，然后不用运算符重载写了一个函数进行Decimal类型的乘法

为了高效，lhs和rhs的入参都是Decimal指针类型

所以代码可能是这样

```cpp
Decimal mul(Decimal* lhs, Decimal* rhs) {
    int new_flag = (*lhs)->flag & (*rhs)->flag;
    // ... 各种deref之后二者位运算
    return (*lhs) * (*rhs);
}
```

大量的*、&、->使得可读性变差，那我为什么不用引用然后直接写lhs * rhs，重载运算符里rhs自然会以指针传参，写起来方便

就像rust_decimal库比bigdecimal-rs的优势，没必要在每个运算符两边加上*或&去提高运算性能，所以rust_decimal用起来就很舒服，而bigdecimal-rs的运算符两边都要加上&让人恶心

知识扩展:

sizeof(引用) = 引用的实例变量的内存大小

在64位编译器中，sizeof(指针)=8

C/C++的指针类型和deref格式也很好记，例如

类型右边一个星号表示，例如Node*表示Node的指针类型

变量名左边一个星号表示 deref

```cpp
ListNode head = ListNode{.val=1, .next=NULL};
ListNode *head_ptr = &head;
ListNode& head_ref = head;
```

## free要和malloc配合使用

下面这段代码运行时会报错，因为这里的head不是堆内存中的head

```cpp
ListNode head = ListNode{.val=1, .next=NULL};
ListNode *head_ptr = &head;
free(head_ptr);
```

正确做法是malloc申请堆内存，使用后用free释放

## NULL和nullptr的区别

当我尝试往BFS双端队列中插入NULL哨兵节点时，CLion建议我用nullptr

nullptr是C++11新推出的，带类型的null

```cpp
deque<Node*> queue = deque<Node*>();
queue.push_back(node);
queue.push_back(NULL);
```

## auto自动类型推断

在C++14版本，auto可以做增强型for循环或函数返回值类型的type inference

所以`for (Node* each : node->children)`可以写成:

`for (auto each : node->children)`

还有`int fn()`可以写成`auto fn() -> int`或`auto fn()`

这里的-> int更像是Python的typehint，不会影响编译器编译g

## Cmake多个可执行文件

cmake编译器就选g++就行了，因为g++还能编译C语言代码，但是gcc不能编译C++的代码

```
add_executable(combinations leetcode/backtracking/combinations.cpp)
add_executable(transpose_matrix leetcode/easy/transpose_matrix.cpp)
add_library(
        leetcode/backtracking/combinations.cpp
        leetcode/easy/transpose_matrix.cpp
#        leetcode/linked_list/linked_list.hpp
)

target_link_libraries(combinations my_lib)
target_link_libraries(transpose_matrix my_lib)
```

以上配置可以让CLion识别多个cpp文件的main函数，缺点是源文件会编译两次(好在C++编译速度快)

.h和.hpp文件可以不加到add_library中

## g++指定C++版本

mac系统的g++默认是不支持一些C++11以后的feature，所以可能需要指定c++的版本才能编译通过

> g++ -std=c++11 remove_duplicates_from_sorted_list.cpp linked_list.hpp

---

最终的代码如下，击败了98%的C++记录

```cpp
static int maxDepth(Node *root) {
    if (root == nullptr) {
        return 0;
    }
    int depth = 0;
    deque<Node*> queue = deque<Node*>();
    queue.push_back(root);
    queue.push_back(nullptr);
    while (!queue.empty()) {
        Node* node = queue.front();
        queue.pop_front();
        if (node == nullptr) {
            depth++;
            if (queue.empty()) {
                break;
            }
            queue.push_back(nullptr);
            continue;
        }
        for (Node* child_node : node->children) {
            queue.push_back(child_node);
        }
    }
    return depth;
}
```
