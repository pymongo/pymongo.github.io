# [解决 mold 源码编译报错](/2022/11/mold_compile_fail_include_span_not_found.md)

mold 已经加入到 ubuntu 22.04 或更高版本发行版的官方源中，但在 ubuntu 20.04 中还只能通过源码进行编译，编译报错如下

```
/home/wuaoxiang/mold/mold.h:17:10: fatal error: span: No such file or directory
   17 | #include <span>
      |          ^~~~~~
```

搜 github issue 后，解决方案说是系统的 C++ 版本太低了，mold 需要支持 C++ 20 的编译器才能编译

难怪 instal-deps 脚本里面给 ubuntu 装了一个 g++-10

通过 cmake 的 CMAKE_CXX_COMPILER 参数使用更高版本的 g++ 而非系统的 g++

> cmake -DCMAKE_CXX_COMPILER=g++-10 --build . -j $(nproc) --verbose