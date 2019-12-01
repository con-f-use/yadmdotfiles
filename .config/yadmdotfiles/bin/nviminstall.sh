#!/bin/bash
description="./$0 -h
Locally build and install neovim from source without root.

date: Sun Dec  1 21:02:12 CET 2019
author: confus <con-f-use@gmx.net>" 

libfile="$HOME/.config/yadmdotfiles/bash/jcgb.bash"
[ -r "$libfile" ] &&
    source "$libfile" ||
    { 2>echo "Requires '$libfile'!"; exit 1; }

main() {
    oldpwd=$(pwd)
    cd $(mktemp -d)
    trap "cd '$oldpwd'; rm -rf $(pwd)" ERR EXIT
    git clone "https://github.com/neovim/neovim.git"
    cd neovim
    git co stable
    make -j CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=/home/jan/.local/"
    make install
    cd "$oldpwd"
}

if [ "$0" = "$BASH_SOURCE" ]; then
    usage "$@"
    main "$@"
fi

