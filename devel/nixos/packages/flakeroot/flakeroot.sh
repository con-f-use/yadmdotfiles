#!/bin/sh

flakeroot="$PWD"
while
    [ ! -f "$flakeroot/flake.nix" ] && [ -d "$flakeroot" ]
do
    flakeroot=${flakeroot%/*}
done
echo "$flakeroot"
