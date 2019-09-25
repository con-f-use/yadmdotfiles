#!/bin/bash

#head -c -1 # only first line, no newlines

#pass conserve/hdshort | 
#    ssh -o "UserKnownHostsFile=~/.ssh/known_hosts.initramfs" \
#        -i "/home/$USER/.ssh/id_rsa.conserve.dropbear" \
#        root@192.168.0.${1:-11} \
#        '/sbin/cryptsetup --allow-discards luksOpen /dev/disk/by-uuid/abfe39fa-ff84-40ec-82c6-31a33ffc5fd8 sda3_crypt && kill $(cat /run/initramfs/plymouth.pid)'

# conserve 3
pass conserve/hdshort | 
    head -c -1 |
    ssh -p 3022 root@192.168.0.${1:-10} cryptroot-unlock


# old version: pass conserve/hdlong
