#!/usr/bin/env bash
set -o errexit -o pipefail -o nounset ${DEBUG:+-o xtrace}
err() { echo -e "\033[0;31mError:\033[0m $&" 1>&2; exit 1; }

test -t 0 ||
    err 'Not in an interactive shell, but user prompts necessary!'

# serverpw=$(mktemp -t bcvpn_cache_XXXX)
# trap "rm -f '$serverpw'" ERR EXIT

gopass show --nosync --password Infrastructure/janpw | sudo -S true || true
sleep 2

sudo barracudavpn --verbose --start \
    --config "$HOME/.config/barracudavpn/" \
    --login "jbischko@barracuda.com" \
    --serverpw "$(gopass show --nosync --password Cuda/cudaws)"

while true; do printf '%(%H:%M:%S)T ' -1; sleep 8; done &
ping -i 8 10.17.6.120
