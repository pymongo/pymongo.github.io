# [RISC-V 汇编写 swap](/2023/08/riscv_asm_swap_two_integer.md)

## 复习 intel/AT&T asm
由于 Unix/gcc 都出自贝尔实验室也就是后来的 AT&T 所以 gcc 默认用 AT&T 语法的汇编器(ar)

> 只有 x86 的 gcc 支持 -masm=intel 输出 intel syntax, ARM/RISC-V 都不支持

||AT&T|intel|
|---|---|---|
|operand order|dst, str|src, dst|
|dereference|(reg)|[reg]|

deref example: movl (%rdi), %eax copies the value from the memory address pointed to by %rdi into the %eax register

> ARM asm similar to AT&T but use `[]` to deref like intel

## Intermediate value
我的理解就是常量，addi = add Intermediate

例如 RISC-V `addi sp, sp, -48` 就是将栈顶指针偏移，准备出 48 byte 栈内存空间

## RISC-V 寄存器
我的学习心得是 汇编语言=寄存器+指令，31 个寄存器功能我参考这个文档 <https://github.com/riscv-non-isa/riscv-asm-manual/blob/master/riscv-asm.md>

注意 GPIO 并不是 51 单片机那样一个 8bit 寄存器对应 8 个 IO 引脚高低电平，树莓派的 GPIO 是通过驱动控制某几个寄存器进而控制 SOC 上 GPIO 的电路

|register|ABI|description|
|---|---|---|
|x0|zero|hard write zero ignore write|
|x1|ra|return address for jump|
|x2|sp|stack pointer|
|x3|gp|global pointer for static data area|
|x4|tp|thread pointer for thread-local var/context|
|x5-x7,x28-x31|t0-t6|temporary register|
|x8|fp/s0|frame pointer or saved register|
|x9,x18-x27|s1-s11|temp/saved register|
|x10,x11|a0,a1|function argument or return value register|
|x12,x17|a2,a7|function argument register|

除了 general register 还有以下几个特殊寄存器
- pc: Program Counter, address of the current instruction being executed


## 试试编译汇编

我还不会写汇编，可以先写出 C 代码编译出汇编来学习下

```c
void swap(int* a, int* b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}
```

> riscv64-unknown-elf-gcc -O3 -S swap.c

```
lw	a4,0(a1)
lw	a5,0(a0)
sw	a4,0(a0)
sw	a5,0(a1)
ret
```

还好 atomic locks 一书中学到过 ARM 的 lw/sw 表示 load/store 32bit

`lw	a4,0(a1)` 从读 a1 值所表示的内存地址，偏移 0 byte 读取 4 byte 存放到 a4

如果是无优化的话生成的汇编指令更多

再看看 ARM 版本的汇编，基本跟 RISC-V 一样

```
ldr	w3, [x1]
ldr	w2, [x0]
str	w3, [x0]
str	w2, [x1]
ret
```

最后看看 x86 版本

```
movl	(%rdi), %eax
movl	(%rsi), %edx
movl	%edx, (%rdi)
movl	%eax, (%rsi)
ret
```
