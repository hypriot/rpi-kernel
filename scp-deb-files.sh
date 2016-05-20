#!/bin/bash

BOARD=192.168.2.103
VERSION=20160514-190208

scp raspberrypi-kernel_${VERSION}_armhf.deb pirate@${BOARD}:
scp raspberrypi-bootloader_${VERSION}_armhf.deb pirate@${BOARD}:
scp libraspberrypi0_${VERSION}_armhf.deb pirate@${BOARD}:
scp libraspberrypi-dev_${VERSION}_armhf.deb pirate@${BOARD}:
scp libraspberrypi-bin_${VERSION}_armhf.deb pirate@${BOARD}:
scp libraspberrypi-doc_${VERSION}_armhf.deb pirate@${BOARD}:
scp linux-headers-4.4.10-hypriotos+_4.4.10-hypriotos+-4_armhf.deb pirate@${BOARD}:
scp linux-headers-4.4.10-hypriotos-v7+_4.4.10-hypriotos-v7+-2_armhf.deb pirate@${BOARD}:
