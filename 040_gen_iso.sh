#!/bin/sh
# By default, gen_binary generates the ISO-Hybrid for CD/DVD and USB and the chroot.
# echo "lb binary | tee lb_binary.log"
# echo " minutes"

lb binary | tee lb_binary.log

if [ -f "binary.hybrid.iso" ]
then
  echo "Image is in: `pwd`/binary.hybrid.iso"
else
  echo "Some problem ocurred, take a look at the `pwd`/lb_binary.log file"
  exit 1
fi


