#!/usr/bin/bash

watch_fly() {
    fl=$(grep -RFil dragonfly /proc/asound/card* | head -n1)
    watch -n 0.1 cat "$fl"
}

if [ "$0" = "$BASH_SOURCE" ]; then
    watch_fly "$@"
fi

