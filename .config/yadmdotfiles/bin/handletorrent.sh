#!/usr/bin/env bash
# encoding: UTF-8, break: linux, indent: 4 spaces, lang: bash 3+/eng
description="$0 -h | [args...]
Forward magnetlinks/torrents to deluge.

author: <con-f-use@gmx.net>"

libfile="$HOME/.config/yadmdotfiles/bash/jcgb.bash"
[ -r "$libfile" ] &&
    source "$libfile" ||
    { 2>echo "Requires '$libfile'!"; exit 1; }

main() {
    loguri="$HOME/handletorrent.log"
    #deluge=/nix/store/*deluge-*/bin/deluge-console 
    deluge=deluge-console 
    if ! command -v deluge-console &>/dev/null; then
        if command -v apt-get &>/dev/null; then
            sudo apt-get install deluge-console
        else
            echo "Please install deluge console!" 1>&2
        fi
    fi

    #echo "Whoami: $(whoami)" >> $loguri
    #echo "time: $(time)" >> $loguri
    #echo "Path: $PATH" >> $loguri
    #echo "Arg: $1" >> $loguri
    #echo "CONSERVEIP: $CONSERVEIP" >> $loguri

    #transmission-remote conserve -n confus:757531 -a "$1"
    # deluge-console "connect 192.168.0.10 localclient 41f48e42c5b614369455582626cf2477f5eabd4b; config -s max_upload_speed 30.0"
    # deluge-console "connect 192.168.0.10 localclient 41f48e42c5b614369455582626cf2477f5eabd4b; config -s max_download_speed 6000.0"


    ssh conserve deluge-console "'connect 192.168.0.10 localclient $(gopass show conserve/deluge-local); add $1'" ||
    $deluge "connect 192.168.0.10 localclient $(gopass show conserve/deluge-local); add $1" ||
    $deluge "connect conserve.dynu.net/deluge conserve $(systemd-ask-password conserve deluge); add $1"
}

if [ "$0" = "$BASH_SOURCE" ]; then
    usage "$@"
    main "$@"
fi
