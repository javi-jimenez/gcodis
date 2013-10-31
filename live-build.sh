#!/bin/sh

# Source: http://stackoverflow.com/questions/920755/how-to-get-script-file-path-inside-script-itself-when-called-through-sym-link
if [ -L $0 ] ; then
    DIR=$(dirname $(readlink -f $0)) ;
else
    DIR=$(dirname $0) ;
fi
# cd into $DIR and all script calls are local to the script path
cd $DIR
BASE_DIR=`pwd`


#for distro in `find conf/ -type d --max-depth 1`
for distro in `cd $BASE_DIR/conf ; find * -maxdepth 1 -type d | cut -f 2 -d '/'`
do
  cd $BASE_DIR
  echo "Distro $distro found in $BASE_DIR/conf/$distro/"
    for machine in "server" "client"
    do
      echo "Build $machine"
      mkdir -p $BASE_DIR/build/$distro/live-build-$distro-$machine/
      echo "Configuring live-build for $machine"
      cd "$BASE_DIR/build/$distro/live-build-$distro-$machine/"
      lb config --mirror-bootstrap http://cdn.debian.net/debian/ \
          --mirror-binary http://cdn.debian.net/debian/ \
	  --security true \
	  --backports false \
	  --debian-installer live \
          --distribution wheezy \
          --architectures i386 \
	  --mode debian
#  --volatile false \ # in unstable doesn't exists that option
      cd -
      echo "Copying requested '$machine' packages to the build dir."
      for package in `cat $BASE_DIR/conf/$distro/$machine.packages | sort -u`
      do
	  cp -v $BASE_DIR/build/packages/$package*.deb $BASE_DIR/build/$distro/live-build-$distro-$machine/config/packages.chroot/
      done
      echo "Building the $distro $machine with live-build."
      cd $BASE_DIR/build/$distro/live-build-$distro-$machine/
      echo "live-build.sh: in `pwd` doing 'lb build' for $machine of $distro"
      #      lb bootstrap
      #      lb chroot
      lb build
      cd -
    done
done
