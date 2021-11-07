# rustc compiler arch

## query-based compiler / query compiler

rustc 的总体方向是朝向 query-based 的方向在发展

analysis, codegen 大体纳入到了query框架里

但是 resolve 还不行，目前还是有什么 Resolver 啊什么的东西

越来越逼真 prolog (
