#!/usr/bin/env bash
# Give information about the current nix environment

ls -al /nix/var/nix/profiles/ /nix/var/nix/profiles/per-user/* /nix/var/nix/profiles/per-user/*/channels/
for udir in /home/*; do
    (cd "$udir/instantos/instantnix/" && pwd && git describe --always && git status)
    echo -e "\n"
done

