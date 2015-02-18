sudo apt-get update

# needed by compile-kernel
for package in git-core build-essential libncurses5-dev bc tree fakeroot devscripts binfmt-support qemu qemu-user-static debootstrap kpartx lvm2 dosfstools apt-cacher-ng debhelper quilt; do
  sudo apt-get install -y $package
done
