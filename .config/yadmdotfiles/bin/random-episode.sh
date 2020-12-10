#!/usr/bin/env bash
# Opens provided number of random video file found in the given location.
#
# Usage: ./random-episode.sh [folders]... [number]
#

for last; do true; done

(( i=0 ))
if [ "$last" == "--all" ]; then
    set -- "${@:1:$(($#-1))}"
    (( i=-2 ))
fi

# Check if last argument is a number
case $last in
    ''|*[!0-9]*) last=1 ;; # No number given
    *) set -- "${@:1:$(($#-1))}" ;; # Remove last argument
esac

echo ""

find "$@" -type f -iregex '.*\(avi\|mp4\|mkv\|m4v\|mpg\|mpeg\|mpeg2\|mpeg4\|ogm\|ogg\|ogx\|ogv\|h264\|264\|m2p\|m4v\|xvid\|h265\|265\|hdmov\|mp2v\|hvec\|webm\|vid\|avc\|exo\|tts\|wmv\|wm\|xmwv\)$' -print0 |
    sort -Rz | #cut -d $'\0' -f-$last |
    while IFS= read -r -d $'\0' file; do
        file=$(readlink -f "$file")
        echo "$i: $file"
        /nix/store/xgr6m2f4rpgjnb8lymxrlvqvcwmmq6rv-vlc-3.0.11.1/bin/vlc --one-instance --playlist-enqueu "$file" &
        if (( i==0 )) || (( i==-2 )); then sleep 2; (( i++ )); fi
        if (( i>0 )); then (( i++ )); fi
        if (( i>last )); then break; fi
    done

echo ""

