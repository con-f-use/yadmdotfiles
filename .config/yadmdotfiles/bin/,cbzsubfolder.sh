#!/usr/bin/env bash
# coding: UTF-8, break: linux, indent: 4 spaces, lang: bash/eng
description=\
"Loops over the given directory and compresses images in first level
subfolders. Output format is a .cbz comic book file.

Usage:
    $0 <dir> [--nodelete]
"

create_cbzs() {
    srcdir=${1:?Need source dir as first argument}
    target=${2:?Need target filename as second argument}

    # Put images in archive
    zip \
        "$target" \
        "$srcdir"/*.jpg "$srcdir"/*.jpeg "$srcdir"/*.png "$srcdir"/*.gif "$srcdir"/*.bmp "$srcdir"/*.tiff

    # zipping successful -> remove leftovers
    if [ "$?" == "0" ] && [[ ! $3 =~ --nodelete ]]; then
        echo trashing successfully zipped images... 1>&2
        trash-put "$srcdir"/*.jpg "$srcdir"/*.jpeg "$srcdir"/*.png "$srcdir"/*.gif "$srcdir"/*.bmp "$srcdir"/*.tiff
        [ "$(ls -A "$srcdir")" ] || rmdir "$srcdir"
    fi
}

main() {
    search_dir="$(readlink -f "${1:?Need a directory to search as first argument}")"
    shift || true
    find "$search_dir" -type d -links 2 -not -empty -print0 | sort -zu |
        while IFS= read -r -d $'\0' dir; do
            [ "$dir" == "." ] && continue

            dir="$(readlink -f "$dir")"

            ,fiximgext "$dir"

            cbzname=$(basename "$dir")
            bla=$(basename "$(dirname "$dir")")
            grep -iqE '^(gallery|issue|part|vol|volume|extra|extras|artwork|no text)' <<< "$cbzname" && cbzname="$bla-$cbzname"
            cbzname=$(sed 's/ /_/g' <<< "$cbzname")
            create_cbzs "$dir" "$dir/../$cbzname.cbz" "$*"

            # Do it again if containing dir has pictures
            dir="$(readlink -f "$dir/..")"
            if [ ! "$search_dir" = "$dir" ] && find "$dir" -maxdepth 1 -type f -regextype egrep -iregex ".*(jpg|jpeg|png|gif|bmp|tiff)$" -print -quit | grep -E ".+"; then
                ,fiximgext "$dir"
                create_cbzs "$dir" "$dir/$(basename "$(readlink -f "$dir") | sed 's/ /_/g'").cbz" "$*"
            fi
    done
}

if [ "$0" = "$BASH_SOURCE" ]; then
    if [ -z "$1" ]; then
        1>&2 echo "$description"
        exit 1
    fi
    if [ "$(readlink -f "$HOME")" = "$(pwd)" ]; then
        1>&2 echo "Not in $HOME"
        exit 1
    fi
    shopt -s nocaseglob   # Case insensitive globbing
    main "$@"
fi
