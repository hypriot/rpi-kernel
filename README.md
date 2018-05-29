# rpi-kernel [![Circle CI](https://circleci.com/gh/hypriot/rpi-kernel.svg?style=svg)](https://circleci.com/gh/hypriot/rpi-kernel)

Build a Raspberry Pi 0/1 and 2/3/3+ kernel with all kernel modules running Docker.

## Build inputs

### Kernel git commit

In the build script `scripts/compile_kernel.sh` there is a git commit hash to pin the build to this exact commit to make it reproducible.

If you want to build another kernel version, have a look at the upstream repo [https://github.com/raspberrypi/linux](https://github.com/raspberrypi/linux) and check for a good git commit hash and change the line

```bash
LINUX_KERNEL_COMMIT="c8baa9702cc99de9614367d0b96de560944e7ccd"
```

### Kernel configs

In the local directory `kernel_configs/` are two configuration files for Pi 0/1 and Pi 2/3/3+.

* `rpi1_docker_defconfig`
* `rpi2_3_docker_defconfig`

These configuration files are created from an initial `make menuconfig` and activating all kernel modules we need to run docker on the Raspberry Pi.

The differences to the upstream Raspberry Pi kernel is

```
$ diff kernel_configs/rpi1_docker_defconfig /var/kernel_build/cache/linux-kernel/arch/arm/configs/bcmrpi_defconfig
16d15
< CONFIG_MEMCG_SWAP=y
18,20d16
< CONFIG_CFS_BANDWIDTH=y
< CONFIG_RT_GROUP_SCHED=y
< CONFIG_CGROUP_PIDS=y
25d20
< CONFIG_CGROUP_PERF=y
354,355d348
< CONFIG_NET_L3_MASTER_DEV=y
< CONFIG_CGROUP_NET_PRIO=y
461d453
< CONFIG_IPVLAN=m
```

## Build outputs

### Kernel deb packages

The two relevant kernel deb packages are copied to `build_results/kernel/${KERNEL_DATETIME}/`.

* `kernel-commit.txt`
* `raspberrypi-kernel_${KERNEL_VERSION}_armhf.deb`
* `raspberrypi-kernel-headers_${KERNEL_VERSION}_armhf.deb`

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
dpkg -i raspberrypi-kernel_${KERNEL_DATETIME}_armhf.deb

dpkg -i raspberrypi-kernel-headers_${KERNEL_DATETIME}_armhf.deb
```

Reboot your Pi.


## Buy us a beer!

This FLOSS software is funded by donations only. Please support us to maintain and further improve it!

<a href="https://liberapay.com/Hypriot/donate"><img alt="Donate using Liberapay" src="https://liberapay.com/assets/widgets/donate.svg"></a>

