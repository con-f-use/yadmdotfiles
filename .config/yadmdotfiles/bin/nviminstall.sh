#!/bin/bash
description="./$0 -h | --stable
Locally build and install neovim from source without root.

Options:
    --stable    Build from 'stable' instead of latest branch

date: Sun Dec  1 21:02:12 CET 2019
author: confus <con-f-use@gmx.net>"

libfile="$HOME/.config/yadmdotfiles/bash/jcgb.bash"
[ -r "$libfile" ] &&
    source "$libfile" ||
    { 2>echo "Requires '$libfile'!"; exit 1; }


ubuntu_install_prereqs() {
    SUDO=$(commadn -v sudo)
    if command -v apt-get &>/dev/null; then
        $SUDO apt-get install \
            build-essential ninja-build gettext \
            libtool libtool-bin \
            autoconf automake cmake \
            pkg-config unzip
    fi
}

main() {
    ubuntu_install_prereqs
    oldpwd=$(pwd)
    cd $(mktemp -d)
    trap "cd '$oldpwd'; rm -rf $(pwd)" ERR EXIT
    git clone "https://github.com/neovim/neovim.git"
    cd neovim
    if [ "${1:-latest}" = "--stable" ]; then
        git co stable
    fi
    # CMAKE_BUILD_TYPE=RelWithDebInfo
    make -j \
        CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$HOME/.local/"  \
        DCMAKE_BUILD_TYPE=Release
    make install
    python2 -m pip install --user --upgrade pynvim
    python3 -m pip install --user --upgrade pynvim neovim-remote
    #nvim '+PlugUpdate' '+PlugClean!' '+PlugUpdate' '+qall'
    cd "$oldpwd"
}

if [ "$0" = "$BASH_SOURCE" ]; then
    usage "$@"
    main "$@"
fi

