# [RISC-V 函数调用](/2023/08/riscv_function_call_and_return.md)

a0-a7,t0-t6 函数调用者压栈保存寄存器状态

s0-s11 函数被调用者保存寄存器状态

## call 伪指令

> jal x1, 100

x1=pc+4; go to pc+100

x1 就是 ra 寄存器，pc + 100 是被调用函数地址

+4/+100 我理解就是额外多留点栈空间存储寄存器状态

## return 伪指令

> jalr x1, 100(x5)

ra=pc+4; go to x5+100

x5 别名是 t0

---

```
// prologue: 
addi sp, sp, -16
sd ra, 0(sp)

// function body

// epilogue:
ld ra, 0(sp)
addi sp, sp, 16
ret
