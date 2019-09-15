#!/bin/bash
# Backup possibly luksEncrypted drives with disk dump (UNFINISHED!).
# ToDo: Finish!

device=${1:-/dev/sdb}
dd="dd bs=100M conv=notrunc,sync status=progress"

sudo fdisk  -l "$device" > "$dir/fidsk.list"
sudo sfdisk -d "$device" > "$dir/sfdisk.list"

for sub in "$device"*; do
    sn="$(basename "$sub")"
    if sudo cryptsetup luksDump "$sub" &>/dev/null; then # we have a luks device
        sudo cryptsetup luksHeaderBackup "$sub" --header-backup-file "$dir/$sn.luksheader"
        # Unlock
        # mapper=<...>
        # Mount
        # Write zero-byte file in free space
        # rm zero-byte file
        # Unmount
        # $dd "if=$mapper" | gzip -9 -c | openssl aes-192-cbc -salt -e > "$dir/$sn.aes.gz"
    else
        # Mount
        # Write zero-byte file in free space
        # rm zero-byte file
        # Unmount
        # $dd "if=$sub" | gzip -9 -c | openssl aes-192-cbc -salt -e > "$dir/$sn.aes.gz"
    fi

done

# Reverse:
    # sfdisk /dev/sda < /tmp/sda.bak
    # cryptsetup luksHeaderRestore "$sub" --header-backup-file "$sn.luksheader"
    # dd if="$sub.aes.gz" | openssl aes-192-cbc -salt -d | gunzip -c
