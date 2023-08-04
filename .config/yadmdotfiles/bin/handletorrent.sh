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
    target=${1:?No first argument, no idea what to add}
    printf "[%(%c)T] ========================\n\n%s\n---\n" -1 "$*"
    deluge=deluge-console
    export PASSWORD_STORE_DIR=$HOME/.config/password-store/
    command -v deluge-console &>/dev/null ||
        wrn Please install deluge console

    pw=$(
        cat ~/.config/deluge/pw 2>/dev/null || 
        gopass show -o conserve/deluge-local | cat -
    ) || err failed to get password for remote deluge

    ssh jan@192.168.1.10 deluge-console "'connect 127.0.0.1 localclient $pw; add $target'"
    # || $deluge "connect 192.168.0.10 localclient $pw; add $target" ||
    # $deluge "connect conserve.dynu.net/deluge conserve $(systemd-ask-password conserve deluge); add $target"
    echo; echo
}

if [ "$0" = "$BASH_SOURCE" ]; then
    usage "$@"
    main "$@" 2>&1 >>/tmp/handletorrent.log
fi


# $deluge "connect 192.168.0.10 localclient 41f48e42c5b614369455582626cf2477f5eabd4b; config -s max_upload_speed 30.0"; config -s max_download_speed 6000.0" #     #transmission-remote conserve -n confus:757531 -a "$target"
