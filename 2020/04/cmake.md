# [cmake体验](/2020/04/cmake.md)

想做个C++项目练练手，大学课程设计级别的计算器、日历之类的C语言应用又太简单了

我选择做个WebSocket client，比较实用又能练手，主要想了解下cmake又不能联网怎么实现npm那样管理第三方依赖

---

## cmake构建C++项目

mac系统上自带了gcc/g++和cmake，当然也可以用CLion的编译器

首先新建一个文件夹，里面只需要放两个文件：`main.cpp`和`CMakeLists.txt`

CMakeLists.txt:

```
cmake_minimum_required(VERSION 3.16)
project(websocket_client) # project名需要和文件夹名字相同

set(CMAKE_CXX_STANDARD 14) # C++版本

add_executable(websocket_client main.cpp)
```

运行`cmake .`命令会在项目根目录生成一堆文件，里面没有可执行文件

```
cmake .
make
./websocket_client
# 等同于
# g++ -o run main.cpp && ./run
```

为了避免`cmake .`生成的文件污染项目的根目录，可以新建一个build文件夹

```
cd build
cmake ..
make
./websocket_client
```

## cmake添加第三方库

以github上的[websocketpp](https://github.com/zaphoyd/websocketpp) 为例

首先看他们的[Get Start文档](https://docs.websocketpp.org/getting_started.html)

<i class="fa fa-hashtag"></i>
文档的重点1：

> directories: websocketpp: All of the library code and default configuration files.

有用的情报1：repo根目录下就websocketpp文件夹是有用的

<i class="fa fa-hashtag"></i>
文档的重点2：

> WebSocket++ is a header only library.

有用的情报2：C++的library类型有很多，这个库是个header only library，那么cmake导入这个库的语句就只有一种写法

<i class="fa fa-hashtag"></i>
文档的重点3：

> also need to include and/or link to appropriate Boost/system libraries

有用的情报3：这个库还需要依赖boost库

但是，还是没搞懂怎么编译，[官方issue](https://github.com/zaphoyd/websocketpp/issues/769)还没解决

---

所以换一个C++的第三方库练手了，沮丧的是，花了2个小时试了Github上好多个项目，没有一个能让我在main.cpp中引用

唉C++没有像npm那样加一行就能导入第三方库的傻瓜工具，弃坑了，继续写Rust(Cargo真香~)
