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

builds=`cd $BASE_DIR/live-build/ ; find . -maxdepth 1 -type d | cut -f 2 -d '/' | grep -v '^\.'`

for build in $builds
do
  cd $BASE_DIR/live-build/$build

  # Build bootstrap
  echo "Build '$build' found in $BASE_DIR/live-build/$build/"
  echo "`pwd` $BASE_DIR/006_gen_bootstrap.sh"
  $BASE_DIR/006_gen_bootstrap.sh
  # It works!

  # Build chroot
  echo "`pwd` $BASE_DIR/008_gen_chroot.sh"
  $BASE_DIR/008_gen_chroot.sh
  # It works!

  # Build ISO-Hybrid live and installing for CD/DVD, HD and USB
  echo "`pwd` $BASE_DIR/040_gen_iso.sh"
  $BASE_DIR/040_gen_iso.sh

  cd $BASE_DIR/live-build/$build/binary/live/
  echo "`pwd` $BASE_DIR/070_gen_img.sh filesystem.squashfs"
  echo "`pwd` $BASE_DIR/070_gen_img.sh filesystem.squashfs"

  echo "`pwd` $BASE_DIR/060_gen_lxc.sh $BASE_DIR/live-build/$build/binary/live/squashfs-root/"
  echo "`pwd` $BASE_DIR/060_gen_lxc.sh $BASE_DIR/live-build/$build/binary/live/squashfs-root/"

  cd -
done

cd $BASE_DIR

