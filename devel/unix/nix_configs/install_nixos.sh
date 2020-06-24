#!/bin/bash
# Install script helper for NixOs distribution.
#
# Author: con-f-use (at gmx net)
# Date: 24.06.2020

export EDITOR=$(which vim)
export DISK=/dev/disk/by-id/ata-MSATA_256GB_SSD_2020031900269

partition() {
    echo 'Always use the by-id aliases, otherwise ZFS can choke on imports:'
    echo '/dev/disk/by-id/...'
    $DISK=${1:?Please give a disk name to partition DANGER!}

    parted --script "${DISK}" -- \
        mklabel gpt \
        mkpart esp fat32 1MiB 1GiB \
        mkpart primary 512MiB 100% \
        set 1 boot on

    # CREATE AN ENCRYPTED ZFS POOL
    zpool create -f \
        -o ashift=12 \
        -O encryption=on \
        -O compression=on \
        -O keyformat=passphrase \
        -O mountpoint=none \
        rpool \
        "${DISK}-part2"

    # RESERVE DISKSPACE SO COPY-ON-WRITE CAN WORK WHEN THE DISK IS (almost) FULL
    zfs create -o refreservation=1G -o mountpoint=none rpool/reserved

    # CREATE A ROOT PARTITION
    zfs create \
        -o mountpoint=legacy \
        -o xattr=sa \
        -o acltype=posixacl \
        rpool/root
    zfs snapshot rpool/root@blank
    mkdir -p /mnt
    mount -t zfs rpool/root /mnt

    # CREATE A NIX PARTITION
    zfs create \
        -o mountpoint=legacy \
        -o atime=off \
        rpool/nix
    mkdir /mnt/nix
    mount -t zfs rpool/nix /mnt/nix

    # CREATE A HOME PARTITION
    zfs create \
        -o mountpoint=legacy \
        -o compression=on \
        rpool/home
    mkdir -p /mnt/home
    mount -t zfs rpool/home /mnt/home

    # CREATE A BOOT PARTITON
    mkfs.fat -F 32 -n BOOT "${DISK}-part1"
    mkdir -p /mnt/boot
    mount -t vfat "${DISK}-part1" /mnt/boot
}


generate_config() {
    zfs_cfg=${1:-/mnt/etc/nixos/zfs-configuration.nix}
    nixos-generate-config --root /mnt

    echo "Writing '${zfg_cfg}'..."
    echo "
{
   boot.initrd.supportedFilesystems = [ \"zfs\" ];
   boot.supportedFilesystems = [ \"zfs\" ];
   boot.zfs.enableUnstable = true;
   services.zfs.autoScrub.enable = true;
   services.zfs.trim.enable = true
   networking.hostId = \"$(head -c 8 /etc/machine-id)\";

   services.zfs.autoSnapshot = {
     enable = true;
     #frequent = 8; # keep the latest eight 15-minute snapshots (instead of four)
     #monthly = 1;  # keep only one monthly snapshot (instead of twelve)
   };
}
" >> "${zfg_cfg}"
    echo -e "Edit config and then run:\n    nixos-install"
}

wifi() {
    # Use this for temorary wifi connection, if needed.
    interface=${1:?First argument must be interface name}
    ssid=${2:?Second argument must be ssid}
    wifipw=${3:?Third argument must be the WiFi password}
    echo "interface: $interface; ssid: $ssid; wifipw: $wifipw" 
    wpa_supplicant -i "$interface" -B -c<(wpa_passphrase "$ssid" "$wifipw")
}


cleanup() {
    # NOW CLEANUP & REBOOT
    umount /mnt/{home,boot}
    umount /mnt
    swapoff -a
    zfs export -a
}

if [ "$0" = "$BASH_SOURCE" ]; then
    # Ctrl+x Ctrl+e edit long shell line in editor
    if [[ "${DEBUG^^}" =~ ^(1|Y(ES)?|ON|T(RUE)?|ENABLE(ED)?)$ ]]; then
        set -o xtrace
        shopt -s shift_verbose
    fi
    set -o errexit -o nounset -o pipefail
    $DISK=${1:?Please give a disk name to partition (DANGER!)}
fi

