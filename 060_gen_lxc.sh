#!/bin/sh

[ $# -eq 0 ] && echo "Usage: $0 [source dir to convert to LXC container]" && exit 1

# Base dir for the call
# Source: http://stackoverflow.com/questions/920755/how-to-get-script-file-path-inside-script-itself-when-called-through-sym-link
if [ -L $0 ] ; then
    DIR=$(dirname $(readlink -f $0)) ;
else
    DIR=$(dirname $0) ;
fi
# cd into $DIR and all script calls are local to the script path

# random hostname
randhostname=`pwgen -1`

$DIR/deploy_to_lxc_clean gcodis-$randhostname $1 /var/lib/lxc/gcodis-$randhostname | tee deploy_to_lxc_clean-gcodis-$randhostname.log


if [ -d "/var/lib/lxc/gcodis-$randhostname/" ]
then
  echo "LXC container is deployed in '/var/lib/lxc/gcodis-$randhostname'."
else
  echo "Some problem ocurred, take a look at the `pwd`/'deploy_to_lxc_clean-gcodis-$randhostname.log' file."
  exit 1
fi


