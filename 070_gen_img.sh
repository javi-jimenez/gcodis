#!/bin/sh
# Generates a .img file
# Needs grub-template.cfg file be in the same directory as this script.

# Example:
# gen_img.sh live-build/server/binary/live/filesystem.squashfs

# Base dir for the call
# Source: http://stackoverflow.com/questions/920755/how-to-get-script-file-path-inside-script-itself-when-called-through-sym-link
if [ -L $0 ] ; then
    DIR=$(dirname $(readlink -f $0)) ;
else
    DIR=$(dirname $0) ;
fi
# cd into $DIR and all script calls are local to the script path

[ ! -f $DIR/grub-template.cfg ] && echo "Template $DIR/grub-template.cfg not exists, can't continue."

[ $# -eq 0 ] && echo "Usage: $0 live-build/server/binary/live/filesystem.squashfs" && exit 1

echo "$DIR/mkimg.sh $*"

$DIR/mkimg.sh $*

