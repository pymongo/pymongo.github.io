# [RISC-V qemu SBI](/2023/08/riscv_qemu_opensbi.md)

```
$ rustup target list | grep riscv64
riscv64gc-unknown-linux-gnu
riscv64gc-unknown-none-elf
riscv64imac-unknown-none-elf
```

riscv64gc: includes the "G" extension, which stands for "general-purpose." It combines the most commonly used extensions (I, M, A, C) into a single term

In summary, RISC-V64GC and RISC-V64IMAC are similar in terms of the base instruction set (I, M, A, C), but RISC-V64IMAC includes additional instructions for multiply-accumulate operations (MAC) for digital signal processing (DSP) and floating-point calculations

## ELF

ELF = executable or linkable format

想要嵌入式或者写操作系统，工具链必须是与底层系统无关的也就是 none-elf

编译出来的操作系统可执行文件，最简单的运行办法是用工具提取出代码和数据部分(提取成 .bin 文件)放到内存的某个位置，再让 bootloader 从硬盘加载操作系统代码到内存随后跳转到操作系统程序入口内存地址，类似单片机程序烧录那样，这样的操作系统就是最简单的裸的不能运行应用程序的

执行顺序: 固件->bootloader/BIOS->OS

1. 引导过程初始化：启动代码首先会初始化一些硬件设备，如串口、计时器等。这些初始化操作可以确保虚拟机在启动时正常工作。
2. 载入内核和文件系统：启动代码会从存储介质（如磁盘镜像）中加载操作系统内核和文件系统镜像。这通常涉及读取磁盘的扇区数据，并将其复制到内存中的适当位置。
3. 设置启动参数：启动代码会设置一些启动参数，如内核的入口地址、内存的分布等。这些参数将被传递给内核，以便内核能够正确地初始化和运行。
4. 启动内核：启动代码最后会跳转到内核的入口地址，将控制权交给内核。从此时开始，内核将负责系统的进一步初始化和运行

## firmware and OpenSBI

**Supervisor Binary Interface**

It is an interface provided by the RISC-V architecture to enable interaction between the privileged software (such as firmware or operating system kernel) and the underlying hardware

> Firmware refers to a type of software that is embedded in hardware devices. It provides the necessary low-level control and initialization code for the hardware to function properly. Firmware is typically stored in non-volatile memory, such as ROM or flash memory

firmware includes these components:
- SBI: interrupt handling, power management, and virtual memory management
- bootloader
- driver

QEMU uses OpenSBI as a firmware option when emulating RISC-V systems

(luojia 同学做的 RustSBI 真不容易啊)

## qemu 内存布局源码

```
<https://github.com/qemu/qemu/blob/master/hw/riscv/virt.c#L78>
static const MemMapEntry virt_memmap[] = {
    [VIRT_DEBUG] =        {        0x0,         0x100 },
    // 固件的代码在 ROM
    [VIRT_MROM] =         {     0x1000,        0xf000 },
    [VIRT_TEST] =         {   0x100000,        0x1000 },
    [VIRT_RTC] =          {   0x101000,        0x1000 },

    // 中断控制器 core_level_interrupter + platform_level_interrupt_controller
    [VIRT_CLINT] =        {  0x2000000,       0x10000 },
    [VIRT_ACLINT_SSWI] =  {  0x2F00000,        0x4000 },

    [VIRT_PCIE_PIO] =     {  0x3000000,       0x10000 },
    [VIRT_PLATFORM_BUS] = {  0x4000000,     0x2000000 },
    // platform_level_interrupt_controller
    [VIRT_PLIC] =         {  0xc000000, VIRT_PLIC_SIZE(VIRT_CPUS_MAX * 2) },
    [VIRT_APLIC_M] =      {  0xc000000, APLIC_SIZE(VIRT_CPUS_MAX) },
    [VIRT_APLIC_S] =      {  0xd000000, APLIC_SIZE(VIRT_CPUS_MAX) },

    // 串口
    [VIRT_UART0] =        { 0x10000000,         0x100 },
    [VIRT_VIRTIO] =       { 0x10001000,        0x1000 },

    [VIRT_FW_CFG] =       { 0x10100000,          0x18 },
    [VIRT_FLASH] =        { 0x20000000,     0x4000000 },
    [VIRT_IMSIC_M] =      { 0x24000000, VIRT_IMSIC_MAX_SIZE },
    [VIRT_IMSIC_S] =      { 0x28000000, VIRT_IMSIC_MAX_SIZE },
    [VIRT_PCIE_ECAM] =    { 0x30000000,    0x10000000 },
    [VIRT_PCIE_MMIO] =    { 0x40000000,    0x40000000 },
    // 操作系统的代码在 DRAM
    [VIRT_DRAM] =         { 0x80000000,           0x0 },
};
```

## firmware bootloader 部分代码

一些相关的指令预备知识

|||
|---|---|
|lw|load a 32-bit word from memory into a register|
|auipc|add upper immediate to PC|
|addi|calculate the lower 12 bits addr and store to reg t0|
|mhartid 寄存器|硬件线程 id|
|特权指令 csrr||
|jr|寄存器跳转|
|lr/ld|32/64 bit mem->reg|

有的指令含义可以问 gpt 例如 explain riscv instrument auipc t0, %pcrel_hi(fw_dyn) 

```
uint32_t reset_vec[10] = {
    0x00000297,                  /* 1:  auipc  t0, %pcrel_hi(fw_dyn) */
    0x02828613,                  /*     addi   a2, t0, %pcrel_lo(1b) */
    // 去哪个 CPU 执行 当前的 CPU core ID
    0xf1402573,                  /*     csrr   a0, mhartid  */
    0,
    0,
    0x00028067,                  /*     jr     t0 */
    start_addr,                  /* start: .dword */
    start_addr_hi32,
    fdt_load_addr,               /* fdt_laddr: .dword */
    fdt_load_addr_hi32,
    // dtb 表示外设的 device table
                                    /* fw_dyn: */
};
```

bootloader 相关内容重点关注下以下几个函数
- riscv_virt_board_init
- sifive_client_create
- serial_mm_init
- virt_flash_create
- riscv_cpu_reset CPU 上电之后会调用，随后调用 board_init


## qemu 命令解读

以 mit-pdos/xv6-riscv 仓库的 make qemu 为例

> qemu-system-riscv64 -machine virt -bios none -kernel kernel/kernel -m 128M -smp 3 -nographic -global virtio-mmio.force-legacy=false -drive file=fs.img,if=none,format=raw,id=x0 -device virtio-blk-device,drive=x0,bus=virtio-mmio-bus.0
