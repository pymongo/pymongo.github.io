# [LLVM dataflow visualization](2021/10/llvm_dataflow_visualization.md)

LLVM 工具链有一个 opt 的可执行文件，是 optimizer 的缩写

```bash
$ cat c.c
int fn(int val) {
    // can compiler optimize these two if stmt
    if (val < 5) {
        val += 1;
    }
    if (val < 5) {
        val -= 1;
    }
    return val;
}
$ clang -S -emit-llvm c.c -o c.ll
$ opt -dot-cfg c.ll # -cfg aka ControlFlowGraph
```

llvm opt command -dot-* options:
- -dot-cfg, cfg aka ControlFlowGraph
- -dot-cfg-only, same as -dot-cfg but without LLVM IR
- -dot-regions/-dot-regions-only
- -dot-dom/-dot-dom-only, DominatorTree may be a binary_tree
- -dot-callgraph 

你还可以找 rustc_typeck 找 rustc_mir_build 找 rustc_codegen_ssa

---

容易联想到 Rust MIR 的 graphviz 各种可视化
