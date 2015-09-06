# rpi-kernel

Build a Raspberry Pi 1 and 2 kernel with all kernel modules running docker.

## Build inputs

### Kernel configs

In the local directory `kernel_configs/` are two configuration files for Pi 1 and Pi 2.

* `rpi1_docker_kernel_config`
* `rpi2_docker_kernel_config`

These configuration files are created from an initial `make menuconfig` and activating all kernel modules we need to run docker on the Raspberry Pi.

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
