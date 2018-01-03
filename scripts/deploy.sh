#!/bin/bash -e

echo "$CIRCLE_TAG"

if [ "$CIRCLE_TAG" != "" ]; then
  gem install package_cloud
  echo Dry run: package_cloud push Hypriot/rpi/debian/jessie /var/kernel_build/results/kernel-*/*.deb
  package_cloud --help
else
  echo "No release tag detected. Skip deployment."
fi
