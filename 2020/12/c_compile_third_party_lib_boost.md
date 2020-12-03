# [g++或cmake导入第三方库boost](/2020/12/c_compile_third_party_lib_boost.md)

以前觉得C/C++引入第三方库难，不想npm之类一样傻瓜，在我认真学了一遍gcc和rustc如何编译成DLL(Dynamic Linking Library)或SLL(Static Linking Library)之后

并且在我弄懂了以下三种情况下的编译命令后，再回头看C/C++编译第三方库就不难了

1. 用gcc编译可执行文件时如何引入Rust编译的DLL和SLL
2. 用cargo+build.rs编译可执行文件时如何引入C/C++编译的DLL或SLL
3. 用rustc编译可执行文件时如何引入C/C++编译的DLL或SLL

上述三种情况的源码和Makefile构建脚本都在我的[learn_gcc repo](https://github.com/pymongo/learn_gcc)

!> 注意一定要在Linux系统下去学这方面的知识，mac没有大部分gcc相关工具链例如ar,ldd

首先现在Rust/C/C++的库都倾向于使用 header_file + DLL(也就是so文件)，或者说叫header-only library

header文件就是库各种函数的prototype，或者说symbol，就告诉你函数名+入参+返回值，具体代码实现编译到了so里，像个黑盒

就像unistd.h或time.h这些标准库gcc/g++会自动link上相应so文件

gcc默认的头文件搜索路径是`echo | gcc -E -Wp,-v -`，也可以用`-I .`添加一个头文件搜索路径或`-include xxx.h`添加一个头文件一起编译

在Ubuntu上`apt install libboost-all-dev`之后，会在`/usr/lib/${CPU_arch}`多一些so文件，以及在`/usr/include/`多一些头文件

这时候就已经可以直接用g++链接上第三方库boost进行编译了

> g++ boost_example_random.cpp -lboost_random

想在cmake中使用，可以在CMakeLists.txt上加两行:

```
include_directories(/usr/include/boost)
link_directories(/usr/lib/arm-linux-gnueabihf)
```

但是你会发现上述库的路径仅适用于树莓派，要想代码跨平台，cmake各种库文件的路径绝对不能写死

于是根据文档在CMakeLists.txt添加如下内容

```
find_package(Boost)
include_directories(${Boost_INCLUDE_DIRS})

add_executable(boost_example_random boost_example_random.cpp)
target_link_libraries(boost_example_random ${Boost_LIBRARIES})
```

以下是boost_example_random.cpp源码:

```cpp
#include <iostream>
#include <boost/random.hpp>

int main() {
    boost::random::mt19937 gen(time(nullptr));
    boost::random::bernoulli_distribution<> dist;
    std::cout << "Test -lboost_random bernoulli_distribution API: \n";
    for (int i = 0; i < 10; ++i) {
        std::cout << dist(gen) << ' ';
    }
    std::cout << '\n';
}
```
