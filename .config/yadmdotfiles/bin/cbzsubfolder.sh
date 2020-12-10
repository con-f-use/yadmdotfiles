#!/usr/bin/env bash
# coding: UTF-8, break: linux, indent: 4 spaces, lang: bash/eng
description=\
"Loops over the given directory and compresses images in first level
subfolders. Output format is a .cbz comic book file.

Usage: 
    $0 <dir> [--nodelete]
"

main() {
    find "$1" -type d -links 2 -not -empty -print0 |
        while IFS= read -r -d $'\0' dir; do
            [ "$dir" == "." ] && continue

            fiximgext.sh "$dir"

            cbzname=$(basename "$dir")
            bla=$(basename "$(dirname "$dir")")
            grep -iqP '^(issue|episode|extra)' <<< "$cbzname" && cbzname="$bla-$cbzname"

            # Put images in archive
            zip \
                "$dir/../$cbzname.cbz" \
                "$dir"/*.jpg "$dir"/*.jpeg "$dir"/*.png "$dir"/*.gif "$dir"/*.bmp "$dir"/*.tiff

            # zipping successful -> remove leftovers
            if [ "$?" == "0" ] && [[ ! "--nodelete" =~ "$@" ]]; then
                trash-put "$dir"/*.jpg "$dir"/*.jpeg "$dir"/*.png "$dir"/*.gif "$dir"/*.bmp "$dir"/*.tiff
                [ "$(ls -A "$dir")" ] || rmdir "$dir"
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
