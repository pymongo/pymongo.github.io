# [CMake引入boost库](/2020/09/cmake_import_boost.md)

一直不太会C++导入第三方库的操作，所以公司里高性能的项目我一直都是用Rust写(rustup/cargo工具链真香)

今天看了写boost库引入的文章，正好我brew老早之前就安装过boost，就试试吧

记录我C++第一次成功导入第三方库的过程(唉npm/cargo/maven加一行就能加一个第三方库，C++的话真是太复杂了)

如果是在mac系统用brew安装的boost，boost库文件一般都固定在一个路径

首先CMakeLists.txt要加两行

```
include_directories(/usr/local/Cellar/boost/1.73.0/include)
link_directories(/usr/local/Cellar/boost/1.73.0/lib)
```

然后就可以在代码里愉快的使用boost了:

```cpp
#include <iostream>
#include <vector>
#include <boost/math/statistics/univariate_statistics.hpp>

using std::cout;
using boost::math::statistics::mean;

int main() {
    std::vector<int> nums{1,2,3,4,5};
    cout << mean(nums.begin(), nums.end()) << std::endl;
    return 0;
}
```
