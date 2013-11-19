#!/bin/sh
#echo "lb bootstrap | tee lb_bootstrap.log"
#echo "5 minutes"

lb bootstrap | tee lb_bootstrap.log

if [ -d "cache/bootstrap/" ]
then
  echo "Bootstrap is in the directory: `pwd`/cache/bootstrap/"
else
  echo "Some problem ocurred, take a look at the lb_bootstrap.log file"
  exit 1
fi

