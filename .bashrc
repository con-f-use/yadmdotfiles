#!/usr/bin/env bash

# Early exit in non-interactive or nix shells
if [[ -z $PS1 ]]; then return; fi
if [[ -n $IN_NIX_SHELL ]]; then return; fi

export BASHYDM="$HOME/.config/yadmdotfiles/bash"

for fl in /etc/{bash.bashrc,bashrc,skel/.bashrc,profile.d/nix.sh} \
    "$HOME/.bash_aliases" \
    ~/.fzf.bash \
    $BASHYDM/{env,config,local,bashit,bash-it/bash_it.sh,alias,todo}
do
    [ -r "$fl" ] && source "$fl"
done

eval "$(direnv hook bash)"
complete -C /run/current-system/sw/bin/vault vault
export EDITOR=/run/current-system/sw/bin/vim
