#!/usr/bin/env bash

export VEIL_TARGET_HOST
export VEIL_REMOTE_USER
export VEIL_DATA


data() {
  machine=${1:?need machine name as first argument}
  VEIL_DATA=$(nix eval "$(flakeroot)/#nixosConfigurations.$machine.config.veil" --json)
  VEIL_TARGET_HOST=$(jq -r .mainIP <<< "$VEIL_DATA")
  VEIL_REMOTE_USER=$(jq -r .mainUser 2>/dev/null <<< "$VEIL_DATA")
  if [ "$VEIL_REMOTE_USER" = "null" ]; then
    VEIL_REMOTE_USER="$USER"
  fi
}


veil:data() {
  jq . <<< "$VEIL_DATA"
  echo "VEIL_TARGET_HOST: $VEIL_TARGET_HOST;"
  echo "VEIL_REMOTE_USER: $VEIL_REMOTE_USER;"
}


veil:machines() {
  nix eval "$(flakeroot)/#nixosConfigurations" --apply 'builtins.attrNames' --json |
    jq -r '.[]'
}

veil:push() {
  to_clean=()
  trap 'rm --force --verbose "${to_clean[@]}"' ERR EXIT
  while IFS= read -r -d $'\0' d <&3; do
    eval "$(jq -r 'to_entries | .[] | .key + "=" + (.value | @sh) + ";"' <<< "$d")"
    # for x in name group target user script; do echo "$x: ${!x}" done

    path=$(mktemp -t veil_XXXXXXX)
    to_clean+=("$path")
    remote="$VEIL_REMOTE_USER@$VEIL_TARGET_HOST"

    echo "$script" > "$path"
    chmod +x "$path"
    value=$("$path" | cat -)

    echo "$name: ${value:0:1}...${value: -1} (${#value} characters) --> ${remote%@null}:$target" 1>&2
    [ ${#value} -gt 4 ] || {
      echo "script: '$script'" 1>&2
      echo "Error: something went wrong with '$name'!" 1>&2
      exit 1
    }

    if [ "$VEIL_TARGET_HOST" = "null" ]; then
      sudo mkdir -p "${target%/*}"
      echo "$value" | sudo tee "$target" >/dev/null
      sudo chown "$user:$group" "$target"
    else
      # read -p "Password please: " -s pswd
      ssh -t "$remote" "sudo mkdir -p '${target%/*}' && echo '$value' | sudo tee '$target' >/dev/null && sudo chown '$user:$group' '$target'"
    fi
  done 3< <(jq --compact-output --raw-output0 '.secrets | map(.)[]' <<< "$VEIL_DATA")
}


veil:deploy() {
  sudo nixos-rebuild \
    --option 'extra-experimental-features' 'nix-command flakes' \
    --builders '' \
    --target-host "$VEIL_REMOTE_USER@$VEIL_TARGET_HOST" \
    "$@" \
    "$(flakeroot)/#$machine"
}


veil:unlock() {
  target="ssh://root@$VEIL_TARGET_HOST:3022"
  gopass show -o "Infrastructure/$machine" |
    ssh ${DEBUG:+-vvvv} \
      -o UserKnownHostsFile=/dev/null \
      -o StrictHostKeyChecking=no \
      "$target" \
      "$@" \
      cryptsetup-askpass
}


got_root() { timeout 5 ssh "root@$VEIL_TARGET_HOST" whoami | grep -q root; }


flakeroot() {
  while [[ ! -f "${flakeroot=$PWD}/flake.nix" && -d "$flakeroot" ]]; do
      flakeroot=${flakeroot%/*}
  done
  echo "$(readlink -f "$flakeroot")"
}


if [ "$0" = "${BASH_SOURCE[0]}" ]; then
  cmd=${1:?Need an action to perform as first argument (push, unlock)}
  shift
  if [ "$cmd" = "machines" ]; then
    veil:"$cmd" "$@"
    exit
  fi
  machine=${1:?Need a target machine as second argument}
  shift
  set -o errexit -o pipefail -o nounset ${DEBUG:+-o xtrace}
  data "$machine"
  veil:"$cmd" "$@"
fi

