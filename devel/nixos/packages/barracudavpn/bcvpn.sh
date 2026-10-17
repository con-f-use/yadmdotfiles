#!/usr/bin/env bash
set -o errexit -o pipefail -o nounset ${DEBUG:+-o xtrace}
err() { echo -e "\033[0;31mError:\033[0m $*" 1>&2; exit 1; }

test -t 0 ||
    err 'Not in an interactive shell, but user prompts necessary!'

# serverpw=$(mktemp -t bcvpn_cache_XXXX)
# trap "rm -f '$serverpw'" ERR EXIT

gopass show --nosync --password Infrastructure/janpw | sudo -S true || true
sleep 2

# Read the LAN prefix before the tunnel adds overlapping entries.
lan_dev=$(ip -4 route show default | awk '{print $5; exit}')
lan_net=$(ip -4 route show dev "$lan_dev" scope link | awk '{print $1; exit}')

sudo barracudavpn --verbose --start \
    --config "$HOME/.config/barracudavpn/" \
    --login "jbischko@barracuda.com" \
    --serverpw "$(gopass show --nosync --password Cuda/cudaws)"

# The client installs whatever the C2S group policy pushes. When that list
# includes the prefix we're sitting on, its metric-0 route outranks the
# link route and the whole local net goes into the tunnel. barracudavpn.conf
# has no key to refuse a route, so drop it after the fact.
drop_lan_collision() {
    test -n "${lan_net:-}" || return 0
    local i
    for ((i = 0; i < 10; i++)); do
        if ip -4 route show "$lan_net" | grep -q 'dev tun0'; then
            sudo ip route del "$lan_net" dev tun0 &&
                echo "Dropped tunnel route for local net $lan_net" ||
                echo "Warning: could not drop $lan_net via tun0" 1>&2
            return 0
        fi
        sleep 0.5
    done
    return 0  # no collision on this network
}
drop_lan_collision

while true; do printf '%(%H:%M:%S)T ' -1; sleep 8; done &
ping -i 8 10.17.6.120
