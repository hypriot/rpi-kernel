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

There are some *unstabilities* under heavy load, so be careful...

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
