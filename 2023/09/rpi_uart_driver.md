# [树莓派 UART 驱动](/2023/09/rpi_uart_driver.md)

## UART 协议
消息包是: 开始位,8bit,奇偶校验位(optional),结束位

通信开始时双方会有个 resync 的过程同步双方时钟和波特率

```c
struct usb_driver {
    const char *name;
    // 指向一个USB设备ID表的指针，用于匹配与驱动程序兼容的USB设备
    const struct usb_device_id *id_table;
    // 指向一个函数的指针，用于在设备与驱动程序匹配时进行探测（probe）操作
    int (*probe)(struct usb_interface *interface, const struct usb_device_id *id);
    void (*disconnect)(struct usb_interface *interface);
    ...
};
```

上述结构体定义是USB驱动程序描述符的示例，再看看 Rust 树莓派 UART 驱动的设备描述符

```rust
pub struct DeviceDriverDescriptor {
    device_driver: &'static (dyn interface::DeviceDriver + Sync),
    post_init_callback: Option<DeviceDriverPostInitCallback>,
}
```

## 烧录

05_drivers_gpio_uart 会编译出 kernel8.img

```
[w@ww ~]$ lsusb | grep reader
Bus 003 Device 012: ID 14cd:1212 Super Top microSD card reader (SY-T18)
[w@ww ~]$ lsblk
NAME        MAJ:MIN RM   SIZE RO TYPE MOUNTPOINTS
sda           8:0    1     0B  0 disk 
nvme0n1     259:0    0 465.8G  0 disk 
```

```
sudo dd if=/home/w/repos/learningOS/rust-raspberrypi-OS-tutorials-master/05_drivers_gpio_uart/kernel8.img of=/dev/sda bs=4096
sudo partprobe /dev/sda
ls /sys/dev/block

Error opening /dev/sda: No medium found
```

好吧这个报错应该是 SD 卡坏了只识别度读卡器所以有/dev/sda但是卡坏了所以没有任何分区和媒体信息，我斥资在小米之家买了一张新的卡

```
sda           8:0    1  29.1G  0 disk 
└─sda1        8:1    1  29.1G  0 part

sudo dd if=/home/w/repos/learningOS/rust-raspberrypi-OS-tutorials-master/05_drivers_gpio_uart/kernel8.img of=/dev/sda1 bs=4096

4+1 records in
4+1 records out
18256 bytes (18 kB, 18 KiB) copied, 0.00508215 s, 3.6 MB/s
```

结果开机后树莓派红灯绿灯一起亮，说明引导失败

再看看文档 <https://github.com/rust-embedded/rust-raspberrypi-OS-tutorials/blob/master/05_drivers_gpio_uart/README.md#boot-it-from-sd-card>

要用 FAT32 格式 SD 卡准备 dtb config.txt 等文件放在根目录

```
[w@ww A184-2B99]$ pwd
/run/media/w/A184-2B99
[w@ww A184-2B99]$ ls -1
bcm2711-rpi-4-b.dtb
config.txt
fixup4.dat
kernel8.img
start4.elf
```

## mojibake
解决完 USB 转 TTL 不小心把 rxd 的白色线用错成红色杜邦线(电源线)后，minicom 在开机后总算有输出了，不过乱码了(mojibake)

看到引导配置文件 config.txt 有波特率设置项 `init_uart_clock=48000000` 看来教程用的 miniterm 默认是这个波特率所以没有乱码

好吧 rpi 默认配置应该是 1152 开头那个波特率，我去掉 init_uart_clock 这个配置 miniterm 依然能用但 minicom 还是乱码
