#!/bin/sh
# Creates .img GRUB bootable images from a given directory

# Source: http://roscopeco.com/2013/08/12/creating-a-bootable-hard-disk-image-with-grub2/

[ $# -eq 0 ] && echo "Usage: $0 <directory> [size]" && exit 1

[ $# -eq 1 ] && echo "Creating image for the directory $1"

[ ! -d $1 ] && echo "Directory '$1' doesn't exists. Exiting." && exit 1

if [ $# -eq 2 ] ; then
  img_size=$2
else
  chroot_size=`du -s $1/ | cut -f 1`
  # Add 20% of space
  img_size_increment=`awk "BEGIN { printf ( $chroot_size  * 0.2) }" | awk '{ printf ("%d", $1)}'`
  # Put upper limit as 2GiB?
  if [ $img_size_increment -gt 2000000 ] ; then $img_size_increment=2000000 ; fi
  img_size=$(( $chroot_size + $img_size_increment ))
fi

img_name=`basename $1`
img_name="$img_name.img"

echo "Creating $img_name with size $img_size"

dd if=/dev/zero of=$img_name count=$img_size bs=1k
parted --align optimal --script $img_name unit kB mklabel msdos mkpart p ext4 200 $img_size set 1 boot on
kpartx -a $img_name
while [ ! -L /dev/mapper/loop0p1 ]; do sleep 1 ; done
mkfs.ext4 /dev/mapper/loop0p1
echo "mkdir -p build/tmp/p1"
mkdir -p build/tmp/p1
mount -o loop /dev/mapper/loop0p1 build/tmp/p1
cd $1/ ; cp -dpa * ../build/tmp/p1 ; cd ..
echo 'echo "(hd0) /dev/loop0" > build/tmp/device.map'
echo "(hd0) /dev/loop0" > build/tmp/device.map
#grub2-install --no-floppy                                                      \
#              --grub-mkdevicemap=build/tmp/device.map                          \
#              --modules="biosdisk part_msdos ext4 configfile normal multiboot" \
#              --root-directory=build/tmp/p1                                    \
#              /dev/loop0
echo "grub-install --no-floppy --modules="biosdisk part_msdos ext2 configfile normal multiboot" --root-directory=build/tmp/p1  /dev/loop0"
grub-install --no-floppy --recheck --modules="biosdisk part_msdos ext2 configfile normal multiboot" --root-directory=build/tmp/p1 /dev/loop0

# Base dir for the call
# Source: http://stackoverflow.com/questions/920755/how-to-get-script-file-path-inside-script-itself-when-called-through-sym-link
if [ -L $0 ] ; then
    DIR=$(dirname $(readlink -f $0)) ;
else
    DIR=$(dirname $0) ;
fi
# cd into $DIR and all script calls are local to the script path
[ -f $DIR/grub-template.cfg ] && echo "OK, template exists"

# New
uuid=`blkid /dev/mapper/loop0p1 | cut -f 2 -d " " | cut -f 2 -d "=" | sed "s/\"//g"`
sed "s/UUID-GOES-HERE/$uuid/g" $DIR/grub-template.cfg > build/tmp/p1/boot/grub/grub.cfg

umount build/tmp/p1
echo "kpartx -d $img_name"
kpartx -d $img_name

