FROM ubuntu

RUN apt-get update && apt-get install -y curl wget

RUN wget http://archive.raspberrypi.org/debian/pool/main/r/raspberrypi-firmware/raspberrypi-kernel_1.20180313-1_armhf.deb
RUN wget http://archive.raspberrypi.org/debian/pool/main/r/raspberrypi-firmware/raspberrypi-kernel-headers_1.20180313-1_armhf.deb
RUN wget http://archive.raspberrypi.org/debian/pool/main/r/raspberrypi-firmware/raspberrypi-bootloader_1.20180313-1_armhf.deb
RUN wget http://archive.raspberrypi.org/debian/pool/main/r/raspberrypi-firmware/libraspberrypi0_1.20180313-1_armhf.deb
RUN wget http://archive.raspberrypi.org/debian/pool/main/r/raspberrypi-firmware/libraspberrypi-doc_1.20180313-1_armhf.deb
RUN wget http://archive.raspberrypi.org/debian/pool/main/r/raspberrypi-firmware/libraspberrypi-dev_1.20180313-1_armhf.deb
RUN wget http://archive.raspberrypi.org/debian/pool/main/r/raspberrypi-firmware/libraspberrypi-bin_1.20180313-1_armhf.deb
RUN wget http://archive.raspberrypi.org/debian/pool/main/r/raspberrypi-firmware/raspberrypi-firmware_1.20180313-1.debian.tar.xz

