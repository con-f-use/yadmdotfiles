#!/usr/bin/env bash

csrv:push() {
  if ! got_root; then
    username=jan
    NIX_SSHOPTS="-t ${NIX_SSHOPTS:-}"
    opts=--use-remote-sudo
  fi

  if [ -n "${label:-}" ]; then
    printf -v now "%(%y%m%d-%H%M%S)T"
    gitrev=$(git -C '/home/jan/devel/nixos' describe \
      --always --abbrev=6 --dirty --broken --tags || echo "unknown")
    export NIXOS_LABEL_VERSION="$label.$now.$gitrev"
  fi

  # shellcheck disable=SC2086
  nixos-rebuild switch ${DEBUG:+--verbose} ${opts:-} \
    --builders '' \
    --target-host "${username:-root}@$IP" \
    --flake '/home/jan/devel/nixos/#conserve' \
    "$@"
}

csrv:unlock() {
  target=${1:-ssh://root@$IP:3022}
  shift || true
  gopass show -o Infrastructure/conserve6 |
    ssh ${DEBUG:+-vvvv} \
      -o UserKnownHostsFile=/dev/null \
      -o StrictHostKeyChecking=no \
      "$target" \
      "$@" \
      cryptsetup-askpass
}

got_root() { timeout 5 ssh "root@$IP" whoami | grep -q root; }

if [ "$0" = "${BASH_SOURCE[0]}" ]; then
  cmd=${1:?Need an action to perform as first argument (push, unlock)}
  shift
  ${DEBUG:+set -o xtrace}
  csrv:"$cmd" "$@"
fi

