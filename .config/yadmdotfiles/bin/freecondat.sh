#!/usr/bin/env bash

#!/bin/bash
# encoding: UTF-8, break: linux, indent: 4 spaces, lang: bash 3+/eng
description="./$0 -h | [max_num=20 [destination [source]]]
Move oldest to a backup location.

If not provided <destination> and <source> are autodetected.
The parameter <max_num> represents the maximum number of history files moved
in one invocation of this file.

date: Wed Sep 25 10:21:38 CEST 2019
author: con-f-use@gmx.net"

libfile="$HOME/.config/yadmdotfiles/bash/jcgb.bash"
[ -r "$libfile" ] &&
    source "$libfile" ||
    { 2>echo "Requires '$libfile'!"; exit 1; }

create_dest() {
    dest="$1"
    if [ ! -d "$dest" ]; then
        info "Creating '$dest'"
        mkdir --parents "$dest" ||
            err "Cannot create '$dest'!"
    fi
}

movefiles() {
    fl="/media/condat1/HT/antbar"

    dest="${2:-"$fl/old/"}"
    create_dest "$dest"

    source="${3:-"$fl"}"
    limit="${1-20}"

    dbg "$fl $dest $source $limit"

    while IFS= read -r -d $'\0' line ; do
        file="${line#* }"
        #tar rvf "$dest" "$file" &&
        dbg "moving '$file' to '$dest'"
        mv --no-clobber "$file" "$dest"
        let limit-=1
        [[ $limit -le 0 ]] && break
    done < <(
      find "$source" -mindepth 2 -printf '%T@ %p\0' -type f \
          -iregex '.*\(avi\|flv\|mp4\|mkv\|m4v\|mpg\|mpeg\|mpeg2\|mpeg4\|ogm\|ogg\|ogx\|ogv\|h264\|264\|m2p\|m4v\|xvid\|h265\|265\|hdmov\|mp2v\|hvec\|webm\|vid\|avc\|exo\|tts\|wmv\|wm\|xmwv\)$' \
          2>/dev/null | 
            sort --zero-terminated --numeric-sort
    )

    echo "Files written to: $dest"
}

movefolders() {
    fl="/media/condat1/HT/antbar"

    dest="${2:-"$fl/old/"}"
    create_dest "$dest"

    source="${3:-"$fl"}"
    limit="${1-20}"

    dbg "$fl $dest $source $limit"

    while IFS= read -r -d $'\0' line ; do
        folder="${line#* }"
        dbg "moving '$folder' to '$dest'"
        mv --no-clobber "$folder" "$dest"
        let limit-=1
        [[ $limit -le 0 ]] && break
    done < <(
      find "$source" -maxdepth 1 -type d \
          -regextype posix-extended -regex '.*/[0-9]+' \
          -printf '%T@ %p\0' |
            sort --zero-terminated --numeric-sort
    )

    echo "Files written to: $dest"
}

if [ "$0" = "$BASH_SOURCE" ]; then
    usage "$@"
    movefolders "$@"
fi
#sudo rsync -avph --remove-sent-files /home/jan/Downloads/HT /media/condat1 --exclude '*.txt' --exclude '*.part'  --exclude '*.temp*' --exclude '*.ytdl'
