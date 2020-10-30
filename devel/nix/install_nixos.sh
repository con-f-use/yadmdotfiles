#!/bin/bash
# Install script helper for NixOs distribution.
#
# Author: con-f-use (at gmx net)
# Date: 24.06.2020

export EDITOR=$(which vim)
export DISK=/dev/disk/by-id/ata-MSATA_256GB_SSD_2020031900269
export middle=''
export SUDO="sudo"

log() { echo "$@" 1>&2; }

echo "Functions defined in ${BASH_SOURCE}:"

echo partition
partition() {
    echo 'Always use the by-id aliases, otherwise ZFS can choke on imports:'
    echo '/dev/disk/by-id/...'
    export DISK=${1:?Please give name of disk to partition - DANGER!}
    if grep -q /by-id/ <<< "$DISK"; then
        export middle='-part'
    fi

    log "# PARTITIONING ${DISL}"
    "$SUDO" parted --script "${DISK}" -- \
        mklabel gpt \
        mkpart esp fat32 1MiB 1GiB \
        mkpart primary 1GiB 100% \
        set 1 boot on
        
    log "Giving the system a little time to settle..."
    sleep 7

    log "# CREATE AN ENCRYPTED ZFS POOL"
    "$SUDO" zpool create -f \
        -o ashift=12 \
        -O entryption=on \
        -O keyformat=passphrase \
        -O compression=on \
        -O mountpoint=none \
        rpool \
        "${DISK}${middle}2"

    log "# RESERVE DISKSPACE SO COPY-ON-WRITE CAN WORK WHEN THE DISK IS (almost) FULL"
    "$SUDO" zfs create -o refreservation=1G -o mountpoint=none rpool/reserved

    log "# CREATE A ROOT PARTITION"
    "$SUDO" zfs create \
        -o mountpoint=legacy \
        -o xattr=sa \
        -o acltype=posixacl \
        rpool/root
    "$SUDO" zfs snapshot rpool/root@blank

    log "# CREATE A NIX PARTITION"
    "$SUDO" zfs create \
        -o mountpoint=legacy \
        -o atime=off \
        rpool/nix

    log "# CREATE A HOME PARTITION"
    "$SUDO" zfs create \
        -o mountpoint=legacy \
        -o compression=on \
        rpool/home

    log "# CREATE A BOOT PARTITON"
    "$SUDO" mkfs.fat -F 32 -n BOOT "${DISK}${middle}1"
}

echo mount_system
mount_system() {
    log "# MOUNTING NEW FILE SYSTEM"
    "$SUDO" zpool import -a
    "$SUDO" mkdir -p /mnt
    "$SUDO" mount -t zfs rpool/root /mnt
    "$SUDO" mkdir /mnt/nix
    "$SUDO" mount -t zfs rpool/nix /mnt/nix
    "$SUDO" mkdir -p /mnt/home
    "$SUDO" mount -t zfs rpool/home /mnt/home
    "$SUDO" mkdir -p /mnt/boot
    "$SUDO" mount -t vfat "${DISK}${middle}1" /mnt/boot
}

echo generate_config
generate_config() {
    zfs_cfg=${1:-/mnt/etc/nixos/zfs-configuration.nix}
    "$SUDO" nixos-generate-config --root /mnt

    echo "Writing '${zfs_cfg}'..."
    echo "
{
   boot.initrd.supportedFilesystems = [ \"zfs\" ];
   boot.supportedFilesystems = [ \"zfs\" ];
   boot.zfs.enableUnstable = true;
   services.zfs.autoScrub.enable = true;
   boot.zfs.devNodes = \"/dev/disk/by-partuuid\";  # https://discourse.nixos.org/t/cannot-import-zfs-pool-at-boot/4805/14
   #services.zfs.trim.enable = true;
   networking.hostId = \"$(head -c 8 /etc/machine-id)\";

   services.zfs.autoSnapshot = {
     enable = true;
     #frequent = 8; # keep the latest eight 15-minute snapshots (instead of four)
     #monthly = 1;  # keep only one monthly snapshot (instead of twelve)
   };
}
" | "$SUDO" tee "${zfs_cfg}"
    echo "# {$zfs_cfg}" | "$SUDO" tee -a /mnt/etc/nixos/configuration.nix
    echo "DO NOT FORGET TO ENABLE EFI BOOT!"
    echo -e "EDIT CONFIG, then run:\n    nixos-install"
    echo "Reminder: sudo nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware"
}

echo wifi
wifi() {
    # Use this for temorary wifi connection, if needed.
    interface=${1:?First argument must be interface name}
    ssid=${2:?Second argument must be ssid}
    wifipw=${3:?Third argument must be the WiFi password}
    echo "interface: $interface; ssid: $ssid; wifipw: $wifipw" 
    wpa_supplicant -i "$interface" -B -c<(wpa_passphrase "$ssid" "$wifipw")
}

echo cleanup
cleanup() {
    # NOW CLEANUP & REBOOT
    cd /
    "$SUDO" umount /mnt/{home,boot}
    "$SUDO" umount /mnt
    "$SUDO" swapoff -a
    "$SUDO" zpool export rpool # -a
}

if [ "$0" = "$BASH_SOURCE" ]; then
    # Ctrl+x Ctrl+e edit long shell line in editor
    if [[ "${DEBUG^^}" =~ ^(1|Y(ES)?|ON|T(RUE)?|ENABLE(ED)?)$ ]]; then
        set -o xtrace
        shopt -s shift_verbose
    fi
    set -o errexit -o nounset -o pipefail
    partition "$1"
    mount_system
    generate_config
    cleanup
fi

