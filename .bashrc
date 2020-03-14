#!/usr/bin/env bash

export BASHYDM="$HOME/.config/yadmdotfiles/bash"

for fl in /etc/{bash.bashrc,bashrc,skel/.bashrc,profile.d/nix.sh} \
    "$HOME/.bash_aliases" \
    ~/.fzf.bash \
    $BASHYDM/{env,local,bashit,bash-it/bash_it.sh,alias,todo}
do
    [ -r "$fl" ] && source "$fl"
done

