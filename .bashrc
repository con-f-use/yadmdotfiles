#!/usr/bin/env bash

# # Early exit in non-interactive or nix shells
# if [[ -z $PS1 ]]; then return; fi
# if [[ -n $IN_NIX_SHELL ]]; then return; fi

# export BASHYDM="$HOME/.config/yadmdotfiles/bash"

# for fl in /etc/{bash.bashrc,bashrc,skel/.bashrc,profile.d/nix.sh} \
#     "$HOME/.bash_aliases" \
#     ~/.fzf.bash \
#     $BASHYDM/{env,config,local,bashit,bash-it/bash_it.sh,alias,todo}
# do
#     [ -r "$fl" ] && source "$fl"
# done

# eval "$(direnv hook bash)"
# complete -C /run/current-system/sw/bin/vault vault
#source "$(nix-env -q --out-path bash-preexec | cut -d ' ' -f3)/share/bash/bash-preexec.sh"
# source "$(blesh-share)/ble.sh"
#eval "$(atuin init bash)"

export PASSWORD_STORE_DIR="$HOME/.config/password-store/"
export PATH="$HOME/.config/yadmdotfiles/bin:$PATH"
export NIX_SSHOPTS='-i ~/.ssh/id_ed25519_cuda -o IdentitiesOnly=yes -o PreferredAuthentications=publickey -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

jj() { $EDITOR "$HOME/.config/yadmdotfiles/xonsh/xonshrc"; }
kk() { $EDITOR "$HOME/.config/yadmdotfiles/kitty/kitty.conf"; }
vv() { $EDITOR "$HOME/.config/nvim/init.vim"; }
bb() { $EDITOR "$HOME/.bashrc"; }
nn() { cd "$HOME/devel/nixos"; }
function ss() {
    cmd=${1:-switch}
    shift || true
    sudo nixos-rebuild "$cmd" "$@" --flake "$HOME/devel/nixos/#$HOSTNAME" --builders ''
}
