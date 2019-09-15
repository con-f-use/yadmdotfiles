#!/bin/bash
# coding: UTF-8, break: linux, indent: 4 spaces, lang: bash/eng
description=\
"Recursively give all graphical image files in the given directory their
appropriate file extention. Extentions are choosen according to Linux'
'file' utility."

[ -z "$1" ] && { 1>&2 echo "$description\n"; exit 1; }

find "$1" -type f -print0 | \
    while IFS= read -r -d $'\0' fl; do
        ext=$(file -bi "$fl" | grep -Po "(?<=image/)[a-zA-Z0-9]+(?=;)")
        [ -z "$ext" ] && continue
        mv "$fl" "$fl.$ext"
        echo "$fl -> $fl.$ext"
    done
