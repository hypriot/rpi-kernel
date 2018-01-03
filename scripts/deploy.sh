#!/bin/bash -e

echo "$CIRCLE_TAG"
ls "$CIRCLE_ARTIFACTS"

if [ "$CIRCLE_TAG" != "" ]; then
  gem install package_cloud
  echo Dry run: package_cloud push Hypriot/rpi/debian/jessie $CIRCLE_ARTIFACTS/*.deb
  package_cloud --help
else
  echo "No release tag detected. Skip deployment."
fi
