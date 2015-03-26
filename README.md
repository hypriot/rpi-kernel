# rpi-kernel

Build a Raspberry Pi 1 and 2 kernel with all kernel modules running docker.

## Build inputs

### Kernel configs

In the local directory `kernel_configs/` are two configuration files for Pi 1 nad Pi 2.

* `rpi1_docker_kernel_config`
* `rpi2_docker_kernel_config`

These configuration files are created from an initial `make menuconfig` and activating all kernel modules we need to run docker on the Raspberry Pi.

## Build outputs

### Kernel deb packages

The five kernel deb packages are copied to `build_results/kernel/<date-time>/`.

* `libraspberrypi-bin_<date-time>_armhf.deb`
* `libraspberrypi-dev_<date-time>_armhf.deb`
* `libraspberrypi-doc_<date-time>_armhf.deb`
* `libraspberrypi0_<date-time>_armhf.deb`
* `raspberrypi-bootloader_<date-time>_armhf.deb`
* `kernel-commit.txt`
* `linux-firmware-image-3.18.8+_3.18.8+-5_armel.deb`
* `linux-firmware-image-3.18.8-v7+_3.18.8-v7+-6_armel.deb`
* `linux-headers-3.18.8+_3.18.8+-5_armel.deb`
* `linux-headers-3.18.8-v7+_3.18.8-v7+-6_armel.deb`
* `linux-image-3.18.8+_3.18.8+-5_armel.deb`
* `linux-image-3.18.8-v7+_3.18.8-v7+-6_armel.deb`
* `linux-libc-dev_3.18.8+-5_armel.deb`
* `linux-libc-dev_3.18.8-v7+-6_armel.deb`

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
