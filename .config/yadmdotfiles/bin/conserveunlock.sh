#!/bin/bash

echo "$(pass conserve/hdshort)" | ssh -o "UserKnownHostsFile=~/.ssh/known_hosts.initramfs" \
    -i "/home/$USER/.ssh/id_rsa.conserve.dropbear" \
    root@192.168.0.${1:-11} \
    '/sbin/cryptsetup --allow-discards luksOpen /dev/disk/by-uuid/abfe39fa-ff84-40ec-82c6-31a33ffc5fd8 sda3_crypt && kill $(cat /run/initramfs/plymouth.pid)'

# old version: pass conserve/hdlong
