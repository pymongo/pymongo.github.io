## gcc静态链接

[Static and Dynamic Library in C using gcc on Linux](https://medium.com/@adib.grouz/static-and-dynamic-library-in-c-using-gcc-on-linux-354edc5d88d3)

动态链接和静态链接是编译成单个可执行文件的过程中，两种combining/collecting multiple object files的方式。

### object files

- relocatable: static_link_lib?
- shared: dylib, compile-time or runtime loaded into memory by linker
- executable

### Linker enable separate compilation

正是因为linker让开发single executable的代码/模块能实现解耦成多个动态/静态链接库，

例如当database module的代码改变时，只需要recompile and re-link database module to executable/application，

改了哪个动态静态链接库就recompile and re-link改动的库，而不需要重新编译所有源文件，而且每个动态静态链接库还能单独编译/测试 
