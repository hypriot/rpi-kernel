#!/bin/bash
set -e

NUM_CPUS=`nproc`
echo "###############"
echo "### Using ${NUM_CPUS} cores"

# setup some build variables
BUILD_USER=vagrant
BUILD_GROUP=vagrant
BUILD_ROOT=/var/kernel_build
BUILD_CACHE=$BUILD_ROOT/cache
ARM_TOOLS=$BUILD_CACHE/tools
LINUX_KERNEL=$BUILD_CACHE/linux-kernel
RASPBERRY_FIRMWARE=$BUILD_CACHE/rpi_firmware

if [ -d /vagrant ]; then
  # running in vagrant VM
  SRC_DIR=/vagrant
else
  # running in drone build
  SRC_DIR=`pwd`
  BUILD_USER=`whoami`
  BUILD_GROUP=`whoami`
fi

LINUX_KERNEL_CONFIGS=$SRC_DIR/kernel_configs

NEW_VERSION=`date +%Y%m%d-%H%M%S`
BUILD_RESULTS=$BUILD_ROOT/results/kernel-$NEW_VERSION

X64_CROSS_COMPILE_CHAIN=arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian-x64

declare -A CCPREFIX
CCPREFIX["rpi1"]=$ARM_TOOLS/$X64_CROSS_COMPILE_CHAIN/bin/arm-linux-gnueabihf-
CCPREFIX["rpi2"]=$ARM_TOOLS/$X64_CROSS_COMPILE_CHAIN/bin/arm-linux-gnueabihf-

declare -A IMAGE_NAME
IMAGE_NAME["rpi1"]=kernel.img
IMAGE_NAME["rpi2"]=kernel7.img

function create_dir_for_build_user () {
    local target_dir=$1

    sudo mkdir -p $target_dir
    sudo chown $BUILD_USER:$BUILD_GROUP $target_dir
}

function setup_build_dirs () {
  for dir in $BUILD_ROOT $BUILD_CACHE $BUILD_RESULTS $ARM_TOOLS $LINUX_KERNEL $RASPBERRY_FIRMWARE; do
    create_dir_for_build_user $dir
  done
}

function clone_or_update_repo_for () {
  local repo_url=$1
  local repo_path=$2

  if [ -d ${repo_path}/.git ]; then
    cd $repo_path && git pull
  else
    git clone --depth 1 $repo_url $repo_path
  fi
}

function setup_arm_cross_compiler_toolchain () {
  echo "### Check if Raspberry Pi Crosscompiler repository at ${ARM_TOOLS} is still up to date"
  clone_or_update_repo_for 'https://github.com/raspberrypi/tools.git' $ARM_TOOLS
}

function setup_linux_kernel_sources () {
  echo "### Check if Raspberry Pi Linux Kernel repository at ${LINUX_KERNEL} is still up to date"
  clone_or_update_repo_for 'https://github.com/raspberrypi/linux.git' $LINUX_KERNEL
}

function setup_rpi_firmware () {
  echo "### Check if Raspberry Pi Firmware repository at ${LINUX_KERNEL} is still up to date"
  clone_or_update_repo_for 'https://github.com/asb/firmware' $RASPBERRY_FIRMWARE
}

function prepare_kernel_building () {
  setup_build_dirs
  setup_arm_cross_compiler_toolchain
  setup_linux_kernel_sources
  setup_rpi_firmware
}

create_kernel_for () {
  echo "###############"
  echo "### START building kernel for ${PI_VERSION}"

  local PI_VERSION=$1

  # change directory to raspberry pi linux kernel
  cd $LINUX_KERNEL

  # remove all generated files + config + various backup files
  ARCH=arm CROSS_COMPILE=${CCPREFIX[${PI_VERSION}]} make mrproper

  # copy kernel configuration file over
  cp $LINUX_KERNEL_CONFIGS/${PI_VERSION}_docker_kernel_config $LINUX_KERNEL/.config

  echo "### building kernel"
  mkdir -p $BUILD_RESULTS/$PI_VERSION
  ARCH=arm CROSS_COMPILE=${CCPREFIX[$PI_VERSION]} make -j$NUM_CPUS -k
  cp $LINUX_KERNEL/arch/arm/boot/Image $BUILD_RESULTS/$PI_VERSION/${IMAGE_NAME[${PI_VERSION}]}

  echo "### building kernel modules"
  mkdir -p $BUILD_RESULTS/$PI_VERSION/modules
  ARCH=arm CROSS_COMPILE=${CCPREFIX[${PI_VERSION}]} INSTALL_MOD_PATH=$BUILD_RESULTS/$PI_VERSION/modules make modules_install -j$NUM_CPUS

  echo "###############"
  echo "### END building kernel for ${PI_VERSION}"
  echo "### Check the $BUILD_RESULTS/$PI_VERSION/kernel.img and $BUILD_RESULTS/$PI_VERSION/modules directory on your host machine."
}

function create_kernel_deb_packages_for () {
  echo "###############"
  echo "### START building kernel DEBIAN PACKAGES"

  local PI_VERSION=$1
  PKG_TMP=`mktemp -d`

  NEW_FIRMWARE=$PKG_TMP/raspberrypi-firmware_${NEW_VERSION}

  create_dir_for_build_user $NEW_FIRMWARE

  # copy over source files for building the packages
  cp -r $RASPBERRY_FIRMWARE/* $NEW_FIRMWARE/
  cp -r $SRC_DIR/debian $NEW_FIRMWARE/debian
  touch $NEW_FIRMWARE/debian/files

  cp $BUILD_RESULTS/$PI_VERSION/${IMAGE_NAME[${PI_VERSION}]} $NEW_FIRMWARE/boot
  cp -R $BUILD_RESULTS/$PI_VERSION/modules $NEW_FIRMWARE

  # build debian packages
  cd $NEW_FIRMWARE

  dch -v ${NEW_VERSION} --package raspberrypi-firmware 'add Hypriot custom kernel'
  debuild --no-lintian -ePATH=${PATH}:$ARM_TOOLS/$X64_CROSS_COMPILE_CHAIN/bin -b -aarmhf -us -uc
  cp ../*.deb $BUILD_RESULTS/$PI_VERSION

  echo "###############"
  echo "### FINISH building kernel DEBIAN PACKAGES"
}


##############
###  main  ###
##############

# setup necessary build environment: dir, repos, etc.
prepare_kernel_building

# create kernel, associated modules and debain packages
for pi_version in "rpi1" "rpi2"; do
  create_kernel_for $pi_version
  create_kernel_deb_packages_for $pi_version
done

# copy build results to synced vagrant host folder
cp -R $BUILD_RESULTS /vagrant/build_results
