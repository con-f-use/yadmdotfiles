#!/bin/bash
# Mounts / unmounts a special encrypted harddrive (conserve)
# Usage:
# ./moext.sh device-file [storage-name]

[ -b "$1" ] || { 1>&2 echo "Error: No device file."; exit 1; }

case "$2" in
    man*)
        mapper=manja
    ;;
    *)
        mapper=extern
        keyfl=~/.cry-con/cry-con-dat
    ;;
esac

loc="/media/$mapper"

if [ "$keyfile" ]; then
    keyfl="--key-file='$keyfl'"
fi

[ ! -e "$loc" ] && { sudo mkdir -p "$loc"; sudo chattr +i "$loc"; }
[ ! "$(ls -A $DIR)" ] && { 1>&2 echo "Error: '$loc' not empty"; exit 2; }

if [ -n "$(mount | grep $loc)" ]; then
    echo "$loc is mounted. Attempting to unmount..."
    sudo umount $loc
    sudo cryptsetup luksClose "$mapper"
else
    echo "$loc is not mounted. Attempting to mount..."
    sudo cryptsetup luksOpen "$1" "$mapper" "$keyfl"
    sudo mount -t ext4 -o users,exec "/dev/mapper/$mapper" "$loc"
fi

# sudo apt-get install pmount
# sudo -u $USER pmount -w -p "$kf" -e "$1" extern

# sudo cryptsetup luksOpen /dev/sdb1 manjam && sudo mount /dev/mapper/manjam /media/manja/
