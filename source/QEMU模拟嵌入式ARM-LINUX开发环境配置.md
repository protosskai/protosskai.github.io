---
title: QEMU模拟嵌入式ARM LINUX开发环境配置
date: 2020-11-15 19:13:32
categories:
- 嵌入式
tags:
- qemu
- linux
- arm
---

# QEMU模拟嵌入式ARM LINUX开发环境配置

参考：https://blog.csdn.net/zhvngchvng/article/details/107856401#2Linux_35

开发环境：UBUNTU 20.04 64位

## 前言

首先，我们需要了解一些基本概念：
**arm交叉编译器**：在主机上编译能够在arm开发板上运行的代码。
**linux内核**：linux运行的核心代码。
**linux内核模块**：动态可加载内核模块，执行时依赖于内核，可以看做是内核的一个拓展，包含各种驱动程序（驱动开发就主要是这一块）。
**linux设备树**：与硬件相关，用来描述芯片平台及板级差异的。
**根文件系统**：内核启动时挂载的第一个文件系统，用来访问各种目录和文件，与内核互相独立。
**bootloader**：开发板启动时的引导程序，一般使用u-boot来制作。
所以，为了在arm开发板上成功运行Linux系统，我们有如下三个方面的任务：

1. 制作bootloader；
2. 编译linux内核、linux内核模块、linux设备树；
3. 制作根文件系统。
    下面，我们使用qemu虚拟机来上手嵌入式linux的开发。

## qemu和相关工具链的安装

安装qemu有以下命令来完成：

```bash
sudo apt install qemu-system
```

在命令行输入以下内容安装ARM交叉编译工具：

```bash
sudo apt-get install qemu
```

若需要安装较新版本的qemu，可以自行下载源码手动编译安装）
使用`qemu-system-`命令可以查看qemu支持的CPU架构。
使用`qemu-system-arm --version`命令可以查看qemu的版本。
使用`qemu-system-arm -M help`命令可以查看支持的开发板类别。

## Linux内核与设备树编译

下载Linux内核：https://www.kernel.org/
选择长期维护的版本进行下载，这里选择5.3.6

将下载下来的Linux内核拷贝到home目录，使用`tar xvf linux-5.3.6.tar.xz`进行解压缩。
解压好后输入`cd linux-5.3.6/`进入linux内核目录下

修改Makefile：`vim Makefile`
搜索交叉编译关键字，在vim编辑器中输入：`/CROSS_COMPILE`，然后回车
向下移动光标，找到关键字**ARCH**和**CROSS_COMPILE**，按i键进入插入文本模式，将其修改为如下内容：

```bash
ARCH	?= arm
# 注意不要忘记最后的小横线！
CROSS_COMPILE	?= arm-linux-gnueabi-  
```

按Esc键切换为一般模式，输入`:wq`保存并退出。

这里我们选择**vexpress**系列作为我们虚拟开发板，在linux内核目录下，输入`make vexpress_defconfig`对开发板进行配置，编译后生成.config文件.在make的过程中，可能会提示缺少flex和bison而失败，这时用apt安装即可。

```bash
sudo apt install flex
sudo apt install bison
```

配置好后，编译**内核**，生成zImage镜像文件：`make zImage -j6`（多线程编译）
编译**内核模块**：`make modules -j4`
编译**设备树**，获得dtb文件：`make dtbs`
在linux内核目录下，使用qemu运行内核：`qemu-system-arm -M vexpress-a9 -m 512M -kernel arch/arm/boot/zImage -dtb arch/arm/boot/dts/vexpress-v2p-ca9.dtb -nographic -append "console=ttyAMA0"`，该命令指定了开发板类别、内存大小、内核zImage文件、dtb文件、无图形界面、串口。

可以看到内核开始运行起来：

[![DFGnit.md.png](https://s3.ax1x.com/2020/11/15/DFGnit.md.png)](https://imgchr.com/i/DFGnit)

但是卡在了挂载根文件系统处，别急，接着往下看。

## busybox根文件系统制作

首先，关掉之前的qemu进程

使用ps命令查看qemu进程：`ps -a`

[![DFGMz8.png](https://s3.ax1x.com/2020/11/15/DFGMz8.png)](https://imgchr.com/i/DFGMz8)

要是没看到qemu进程，就不用kill，否则，kill掉qemu进程。kill 25906

接下来，使用busybox制作根文件系统。
下载源码：https://busybox.net/downloads/，下载最新版本即可。

[![DFGNiq.png](https://s3.ax1x.com/2020/11/15/DFGNiq.png)](https://imgchr.com/i/DFGNiq)

解压缩：`tar xvf busybox-1.32.0.tar.bz2`
进入busybox源码目录：`cd busybox-1.32.0/`
修改Makefile：`vim Makefile`
在vim编辑器中输入`/CROSS_COMPILE`查找关键字**CROSS_COMPILE**。
向下移动光标，找到关键字所在处，按i键切换到插入模式，并将值修改为`arm-linux-gnueabi-`：

[![DFGaWV.png](https://s3.ax1x.com/2020/11/15/DFGaWV.png)](https://imgchr.com/i/DFGaWV)

按Esc退出插入模式，输入`/ARCH`查找关键字**ARCH**。
向下移动光标，找到关键字，按i切换到插入模式，并将值修改为`arm`：

[![DFGdzT.png](https://s3.ax1x.com/2020/11/15/DFGdzT.png)](https://imgchr.com/i/DFGdzT)

按Esc键，输入`:wq`保存退出。
接着，输入命令`make defconfig`回车等待配置完毕。
也可以使用图形化配置`make menuconfig`，按回车然后进入Settings选项，找到Build Options，点y键将选项Build static binary（编译成静态）选中，然后退出：

[![DFGseJ.png](https://s3.ax1x.com/2020/11/15/DFGseJ.png)](https://imgchr.com/i/DFGseJ)

当输入make menuconfig的时候，会提示找不到curses.h，这时候就要安装libncurses5-dev

```bash
sudo apt-get install libncurses5-dev
```

要是依赖有问题而安装失败的话，可以尝试安装aptitude

```bash
sudo apt install aptitude
```

然后用aptitude安装这个库

```bash
sudo aptitude install libncurses5-dev
```

aptitude会检测冲突后的解决方案，选择一个合适的即可。（若不合适的话，可以选择输入n来查看下一个方案）

回到命令行，直接编译：`make -j4`
然后执行`make install`，生成一个**_install**文件夹。
准备好后，下一步开始制作根文件系统。
输入`cd`回到home目录，新建目录`mkdir rootfs`，进入该目录`cd rootfs/`，将刚才生成的**_install**目录里的所有文件拷贝到该目录下：

```bash
cp -r 你编译busybox的目录/_install/* ./
```

新建目录`mkdir lib`，将arm交叉编译器的库复制过来：

```bash
cp -r /usr/arm-linux-gnueabi/lib/* lib/
```

在rootfs目录下新建目录`mkdir dev/`，进入该目录`cd dev/`，创建节点`sudo mknod -m 666 tty1 c 4 1`（这里创建了一个串口字符设备，**主设备号**为4，**从设备号**为1）。
重复创建多个串口设备，注意分配好从设备号：(重复分配tty2-9，主设备仍未，从设备号为2-9)
创建一个控制台节点：`mknod -m 666 console c 5 1`
创建一个空节点：`mknod -m 666 null c 1 3`
创建好的字符设备用`ls`查看：

[![DFJ9Ts.png](https://s3.ax1x.com/2020/11/15/DFJ9Ts.png)](https://imgchr.com/i/DFJ9Ts)

回到home目录，输入命令`dd if=/dev/zero of=rootfs.ext3 bs=1M count=32`生成虚拟SD卡系统镜像，可以得到一个rootfs.ext3文件。
格式化该镜像：`mkfs.ext3 rootfs.ext3`
挂载该镜像到本地：`mount -t ext3 rootfs.ext3 /mnt -o loop`
将之前准备的rootfs目录下的所有文件都拷贝到该镜像挂载点：`cp -r /home/zvcv/rootfs/* /mnt/`
卸载：umount /mnt/
进入linux源码目录： `cd linux/`
使用qemu启动内核：`qemu-system-arm -M vexpress-a9 -m 512M -kernel arch/arm/boot/zImage -dtb arch/arm/boot/dts/vexpress-v2p-ca9.dtb -nographic -append "root=/dev/mmcblk0 rw console=ttyAMA0" -sd /home/zvcv/rootfs.ext3`，这里比之前多指定了一个sd镜像。
点击回车，进入命令行，linux启动完毕。

[![DFJV6U.png](https://s3.ax1x.com/2020/11/15/DFJV6U.png)](https://imgchr.com/i/DFJV6U)

若要图形化启动，使用命令：`qemu-system-arm -M vexpress-a9 -m 512M -kernel arch/arm/boot/zImage -dtb arch/arm/boot/dts/vexpress-v2p-ca9.dtb -append "root=/dev/mmcblk0 rw console=tty0" -sd rootfs.ext3`

[![DFJqHJ.png](https://s3.ax1x.com/2020/11/15/DFJqHJ.png)](https://imgchr.com/i/DFJqHJ)

## 使用u-boot加载Linux内核

下载源码：[u-boot下载](https://ftp.denx.de/pub/u-boot/)，选择合适的版本即可。
（较新版本的u-boot需要更高版本的gcc来编译，为了方便起见，可以选用较早版本的u-boot）

https://ftp.denx.de/pub/u-boot/u-boot-2017.05.tar.bz2

[![DFYdrF.png](https://s3.ax1x.com/2020/11/15/DFYdrF.png)](https://imgchr.com/i/DFYdrF)

下载后解压缩：`tar xvf u-boot-2020.07.tar.bz2`
切换到目录：`cd u-boot-2020.07`
编辑Makefile文件：`vim Makefile`
查找关键字：`/CROSS_COMPILE`
向下翻，找到**CROSS_COMPILE**，按i键切换模式，修改为如下内容：

[![DFY4VH.png](https://s3.ax1x.com/2020/11/15/DFY4VH.png)](https://imgchr.com/i/DFY4VH)

按Esc键退出插入模式，输入`:wq`保存并退出。
命令行输入`vim config.mk`
查找关键字：`/ARCH`
按i键切换模式，修改关键字的值：

[![DFY7Gt.png](https://s3.ax1x.com/2020/11/15/DFY7Gt.png)](https://imgchr.com/i/DFY7Gt)

按Esc键退出插入模式，输入`:wq`保存并退出。
命令行输入命令进行配置：`make vexpress_ca9x4_defconfig`
配置好后，编译：`make`

如果报以下的错的话

[![DFtseg.png](https://s3.ax1x.com/2020/11/15/DFtseg.png)](https://imgchr.com/i/DFtseg)

可以尝试

```bash
export CROSS_COMPILE=arm-linux-gnueabi-
export ARCH=arm
```

然后

```bash
make vexpress_ca9x4_defconfig
make
```

若make时又出现如下错误：

[![DFtomF.png](https://s3.ax1x.com/2020/11/15/DFtomF.png)](https://imgchr.com/i/DFtomF)

则需要安装device-tree-compiler：`sudo apt-get install device-tree-compiler`

make完成后，启动u-boot：`qemu-system-arm -M vexpress-a9 -m 512M -nographic -kernel u-boot`（注意：按下enter键后，会出现一个2s倒计时，询问你是否停止自动启动，直接回车就可以跳过启动过程中各种外设的加载）
输入命令测试：`help`，可以查看支持的命令。
运行成功后，删除该qemu进程：`ps -a`查找PID号，`kill`命令删除

## 搭建网络开发环境

首先需要配置虚拟网卡，用于分配给qemu。



