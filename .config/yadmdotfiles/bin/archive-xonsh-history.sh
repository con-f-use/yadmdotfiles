#!/usr/bin/env bash

#!/bin/bash
# encoding: UTF-8, break: linux, indent: 4 spaces, lang: bash 3+/eng
description="./$0 -h | [max_num=20 [destination [source]]]
Move oldest few xonsh history json files to a backup location.

If not provided <destination> and <source> are <autodetected> from xonsh.
The parameter <max_num> represents the maximum number of history files moved
in one invocation of this file.

date: Wed Sep 25 10:21:38 CEST 2019
author: con-f-use@gmx.net"

libfile="$HOME/.config/yadmdotfiles/bash/jcgb.bash"
[ -r "$libfile" ] &&
    source "$libfile" ||
    { 2>echo "Requires '$libfile'!"; exit 1; }

main() {
    fl=$(xonsh -c 'history file')
    fl=$(dirname "$(readlink --canonicalize "$fl")")

    dest="${2:-"$fl/old"}"
    if [ ! -d "$dest" ]; then
        info "Creating '$dest'"
        mkdir --parents "$dest" ||
            err "Cannot create '$dest'!"
    fi
    dest="$dest/xonsh-$(date +%y%m%d-%H%M%S).tar"

    source="${3:-"$fl"}"
    limit="${1-20}"

    dbg "$fl $dest $source $limit"

    while IFS= read -r -d $'\0' line ; do
        file="${line#* }"
        tar rvf "$dest" "$file" &&
            rm "$file"
        let limit-=1
        [[ $limit -le 0 ]] && break
    done < <(find "$source" -name "xonsh*.json" -maxdepth 1 -printf '%T@ %p\0' \
        2>/dev/null | sort --zero-terminated --numeric-sort)

    gzip "$dest" > "$dest.gz" &&
        rm "$dest"

    echo "Files written to: $dest.gz"
}

if [ "$0" = "$BASH_SOURCE" ]; then
    usage "$@"
    main "$@"
fi
