# [must use struct tag to](/2023/07/cpp_ok_but_c_not_must_use_struct_tag_to_refer_type.md)

做 codegen 的时候有些 C++ 的库文件也误用了 .h 后缀导致编译报错，记录收集下这类 C 编译报错但 C++ 能编译通过的案例

```c
struct Point {
    int x;
    int y;
};
int main() {
    // struct Point p; // Correct usage in C
    Point p; // Error: Must use 'struct' tag to refer to type
    return 0;
}
```

clang 的报错 `c2.c:7:5: error: must use 'struct' tag to refer to type 'Point'`

高版本 gcc 会提示如何修这个错 `c2.c:7:5: error: unknown type name ‘Point’; use ‘struct’ keyword to refer to the type`

同样的在自引用结构体定义中，C 不允许以下写法但 C++ 可以

```c
struct Node {
    Node *next;
};
```

C 允许的写法是

```c
struct Node {
    struct Node* next;
};

// or

typedef struct Node Node;
struct Node {
    Node* next;
};
```

我更喜欢上一种写法，下面这种写法就像 Node 这个标识符被 shadowing 了
