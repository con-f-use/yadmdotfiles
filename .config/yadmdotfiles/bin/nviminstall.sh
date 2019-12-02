#!/bin/bash
description="./$0 -h
Locally build and install neovim from source without root.

date: Sun Dec  1 21:02:12 CET 2019
author: confus <con-f-use@gmx.net>"

libfile="$HOME/.config/yadmdotfiles/bash/jcgb.bash"
[ -r "$libfile" ] &&
    source "$libfile" ||
    { 2>echo "Requires '$libfile'!"; exit 1; }

ubuntu_install_prereqs() {
    if command -v apt-get &>dev/null; then
        sudo apt-get install \
            ninja-build gettext \
            libtool libtool-bin \
            autoconf automake cmake \
            g++ pkg-config unzip
    fi
}

main() {
    ubuntu_install_prereqs
    oldpwd=$(pwd)
    cd $(mktemp -d)
    trap "cd '$oldpwd'; rm -rf $(pwd)" ERR EXIT
    git clone "https://github.com/neovim/neovim.git"
    cd neovim
    # git co stable
    # CMAKE_BUILD_TYPE=RelWithDebInfo
    make -j \
        CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/.local/"  \
        DCMAKE_BUILD_TYPE=Release
    make install
    python2 -m pip install --user --upgrade pynvim
    python3 -m pip install --user --upgrade pynvim neovim-remote
    cd "$oldpwd"
}

if [ "$0" = "$BASH_SOURCE" ]; then
    usage "$@"
    main "$@"
fi

