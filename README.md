# rpi-kernel

Build a Raspberry Pi 1 and 2 kernel with all kernel modules running docker.

## Build inputs

### Kernel git commit

In the build script `scripts/compile_kernel.sh` there is a git commit hash to pin the build to this exact commit to make it reproducable.

If you want to build another kernel version, have a look at the upstream repo [https://github.com/raspberrypi/linux](https://github.com/raspberrypi/linux) and check for a good git commit hash and change the line

```bash
LINUX_KERNEL_COMMIT="c8baa9702cc99de9614367d0b96de560944e7ccd"
```

### Kernel configs

In the local directory `kernel_configs/` are two configuration files for Pi 1 and Pi 2.

* `rpi1_docker_kernel_config`
* `rpi2_docker_kernel_config`

These configuration files are created from an initial `make menuconfig` and activating all kernel modules we need to run docker on the Raspberry Pi.


## Real Time Kernel

For a Real Time Kernel the only different thing it has to be made is:
RT=1 source scripts/compile\_kernel.sh

## Build outputs

### Kernel deb packages

The five kernel deb packages are copied to `build_results/kernel/${KERNEL_DATETIME}/`.

* `libraspberrypi-bin_${KERNEL_DATETIME}_armhf.deb`
* `libraspberrypi-dev_${KERNEL_DATETIME}_armhf.deb`
* `libraspberrypi-doc_${KERNEL_DATETIME}_armhf.deb`
* `libraspberrypi0_${KERNEL_DATETIME}_armhf.deb`
* `raspberrypi-bootloader_${KERNEL_DATETIME}_armhf.deb`
* `kernel-commit.txt`
* `linux-firmware-image-${KERNEL_VERSION}+_${KERNEL_VERSION}+-5_armel.deb`
* `linux-firmware-image-${KERNEL_VERSION}-v7+_${KERNEL_VERSION}-v7+-6_armel.deb`
* `linux-headers-${KERNEL_VERSION}+_${KERNEL_VERSION}+-5_armel.deb`
* `linux-headers-${KERNEL_VERSION}-v7+_${KERNEL_VERSION}-v7+-6_armel.deb`
* `linux-image-${KERNEL_VERSION}+_${KERNEL_VERSION}+-5_armel.deb`
* `linux-image-${KERNEL_VERSION}-v7+_${KERNEL_VERSION}-v7+-6_armel.deb`
* `linux-libc-dev_${KERNEL_VERSION}+-5_armel.deb`
* `linux-libc-dev_${KERNEL_VERSION}-v7+-6_armel.deb`

## Build with Vagrant

To build the SD card image locally with Vagrant and VirtualBox, enter

```bash
vagrant up
```

### Recompile kernel

Only on first boot the kernel will be compiled automatically.
If you want to compile again, use these steps:

```bash
vagrant up
vagrant ssh
sudo su
/vagrant/scripts/compile_kernel.sh
```

### Update kernel configs

To update the two kernel config files you can use this steps.

```bash
vagrant up
vagrant ssh
sudo su
MENUCONFIG=1 /vagrant/scripts/compile_kernel.sh
```

This will only call the `make menuconfig` inside the toolchain and copies the updated kernel configs back to `kernel_configs/` folder to be committed to the GitHub repo.

## Test kernel

To test the new kernel, copy all DEB packages to your Pi and login as root.
Then install the following packages:

```bash
dpkg -i raspberrypi-bootloader_${KERNEL_DATETIME}_armhf.deb
dpkg -i libraspberrypi0_${KERNEL_DATETIME}_armhf.deb
dpkg -i libraspberrypi-dev_${KERNEL_DATETIME}_armhf.deb
dpkg -i libraspberrypi-bin_${KERNEL_DATETIME}_armhf.deb
dpkg -i libraspberrypi-doc_${KERNEL_DATETIME}_armhf.deb

dpkg -i linux-headers-${KERNEL_VERSION}-hypriotos+_${KERNEL_VERSION}-hypriotos+-1_armhf.deb
dpkg -i linux-headers-${KERNEL_VERSION}-hypriotos-v7+_${KERNEL_VERSION}-hypriotos-v7+-2_armhf.deb
```

Reboot your Pi.

```bash
$ uname -a
Linux black-pearl 4.1.15-hypriotos-rt-rt14-v7+ #2 SMP PREEMPT RT Sat Jan 9 21:09:05 CET 2016 armv7l GNU/Linux
```
Taken from emlid.com and http://kb.digium.com/articles/Configuration/How-to-perform-a-system-latency-test

In the first SSH or console session, run: sudo sudo ./cyclictest -l10000000 -m -n -a0 -t1 -p99 -i400 -h400 -q
sudo ./cyclictest -l100000 -m -n -a0 -t1 -p99 -i400 -h400 -q

```bash
# /dev/cpu_dma_latency set to 0us
# Histogram
000000 000000
000001 000000
000002 000000
000003 000000
000004 000000
000005 000000
000006 000000
000007 000000
000008 000000
000009 000000
000010 000000
000011 000000
000012 000000
000013 000000
000014 000004
000015 249277
000016 8595933
000017 935863
000018 088623
000019 021123
000020 006084
000021 004336
000022 003522
000023 003186
000024 003169
000025 003166
000026 003283
000027 003289
000028 003350
000029 003395
000030 003455
000031 003416
000032 006121
000033 016941
000034 017025
000035 017433
000036 004323
000037 001491
000038 000392
000039 000195
000040 000161
000041 000121
000042 000108
000043 000093
000044 000073
000045 000075
000046 000090
000047 000131
000048 000200
000049 000176
000050 000117
000051 000074
000052 000051
000053 000039
000054 000028
000055 000025
000056 000011
000057 000010
000058 000004
000059 000004
000060 000002
000061 000001
000062 000001
000063 000002
000064 000001
000065 000001
000066 000000
000067 000003
000068 000000
000069 000000
000070 000000
000071 000000
000072 000002
000073 000000
000074 000000
000075 000000
000076 000001
000077 000000

# Total: 010000000
# Min Latencies: 00014
# Avg Latencies: 00016
# Max Latencies: 00076
# Histogram Overflows: 00000
# Histogram Overflow at cycle number:
# Thread 0:


```
In the second SSH or console session, run: sudo hdparm -t /dev/mmcblk0p1
/dev/mmcblk0p1:
 Timing buffered disk reads:  56 MB in  3.09 seconds =  18.14 MB/sec
