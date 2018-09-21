#!/bin/bash -e

echo "Circle Tag: $CIRCLE_TAG"

if [ "$CIRCLE_TAG" != "" ]; then
  apt-get update
  apt-get install -y golang-go
  go get github.com/mlafeldt/pkgcloud/...
  $HOME/go/bin/pkgcloud-push Hypriot/rpi/debian/stretch output/*/raspberrypi-kernel*.deb output/*/linux-libc-dev*.deb

  curl -sSL https://github.com/tcnksm/ghr/releases/download/v0.5.4/ghr_v0.5.4_linux_amd64.zip -o ghr.zip
  unzip ghr.zip
  mkdir ghroutput
  cp output/*/raspberrypi-kernel*.deb ghroutput/

  if [[ $CIRCLE_TAG = *"rc"* ]]; then
    pre=-prerelease
  fi
  ./ghr $pre -u hypriot "$CIRCLE_TAG" ghroutput/

else
  echo "No release tag detected. Skip deployment."
fi
