#!/bin/bash -e

echo "$CIRCLE_TAG"

if [ "$CIRCLE_TAG" != "" ]; then
  gem install package_cloud
  package_cloud push Hypriot/rpi/debian/jessie output/*/*.deb
else
  echo "No release tag detected. Skip deployment."
fi
