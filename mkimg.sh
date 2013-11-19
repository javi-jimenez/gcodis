#!/bin/sh
# Creates .img GRUB bootable images from live-build squashfs generated file.

# Source: http://roscopeco.com/2013/08/12/creating-a-bootable-hard-disk-image-with-grub2/

[ $# -eq 0 ] && echo "Usage: $0 [filesystem.squashfs]" && exit 1

#cd binary/live/
unsquashfs $1 # filesystem.squashfs

img_name="gcodis.img"

# dd if=/dev/zero of=mink.img count=10000 bs=1048576
dd if=/dev/zero of=$img_name count=2000 bs=1048576
# parted --script mink.img mklabel msdos mkpart p ext2 1 10000 set 1 boot on
parted --script $img_name mklabel msdos mkpart p ext4 1 2000 set 1 boot on
kpartx -a $img_name
sleep 1
mkfs.ext4 /dev/mapper/loop0p1
mkdir -p build/tmp/p1
mount -o loop /dev/mapper/loop0p1 build/tmp/p1
#cp -r squashfs-root/* build/tmp/p1
cd squashfs-root/ ; cp -dpa * ../build/tmp/p1 ; cd ..
echo "(hd0) /dev/loop0" > build/tmp/device.map
#grub2-install --no-floppy                                                      \
#              --grub-mkdevicemap=build/tmp/device.map                          \
#              --modules="biosdisk part_msdos ext4 configfile normal multiboot" \
#              --root-directory=build/tmp/p1                                    \
#              /dev/loop0
grub-install --no-floppy --modules="biosdisk part_msdos ext2 configfile normal multiboot" --root-directory=build/tmp/p1  /dev/loop0

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
kpartx -d $img_name

