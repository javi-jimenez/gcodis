#!/bin/sh


#for distro in `find conf/ -type d --max-depth 1`
for distro in `cd conf ; find * -maxdepth 1 -type d ; cd -`
do
  echo "mkdir"
  mkdir -p build/$distro/live-build-$distro-client/
  echo "cd dir created"
  cd build/$distro/live-build-$distro-client/ ; lb config ; cd -
  for package in `cat conf/$distro/client.packages | sort -u`
  do
    echo "cp build/packages/$package*.deb build/$distro/live-build-$distro-client/conf/packages.chroot/"
    cp build/packages/$package*.deb build/$distro/live-build-$distro-client/config/packages.chroot/
  done
  cd build/$distro/live-build-$distro-client/ ; lb build ; cd -

  mkdir -p build/$distro/live-build-$distro-server/
  cd build/$distro/live-build-$distro-server/ ; lb config ; cd -
  for package in `cat conf/$distro/server.packages | sort -u `
  do
    cp build/packages/$package*.deb build/$distro/live-build-$distro-server/config/packages.chroot/
  done
  cd build/$distro/live-build-$distro-server/ ; lb build ; cd -

  echo "$distro server"
  ls build/$distro/live-build-$distro-server/config/packages.chroot/
  echo "$distro client"
  ls build/$distro/live-build-$distro-client/config/packages.chroot/

done
