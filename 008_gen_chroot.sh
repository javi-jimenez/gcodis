#!/bin/sh
#echo "lb chroot | tee lb_chroot.log"
#echo "2.5 minutes"

lb chroot | tee lb_chroot.log

if [ -d "chroot/" ]
then
  echo "Chroot (pre-live install) is in the directory: `pwd`/chroot/"
else
  echo "Some problem ocurred, take a look at the `pwd`/lb_chroot.log file."
  exit 1
fi

