#!/usr/bin/env bash
# Dirty workaround the misguided "security" behavior of barracudavpn
# on NixOS.

err() { echo "Error: $&" 1>&2; exit 1; }

test -t 0 ||
    err 'Not in login shell!'

serverpw=$(gopass show -o Cuda/cudaws | cat)

logpath=$(mktemp -t --suffix .log bcvpn.XXXXXX) ||
    err 'Cannot create logfile!'
trap "rm -f '$logpath'" EXIT ERR # Has sensitive data, ensure deleteion

# This is the real workaournd.
# baracudavpn somehow expects the `ip` command not to be a symlink or
# something (presumably for "security" reasons), so we need to extract
# the calls to ip from the verbose output and run them manually 
# (with sudo), but there's more prolems:
# - Simple output redirect `...2>&1 >"$logpath"` seems to cause
# barracudavpn to supress its verbose output completely, it needs to
# be in an interactive shell, because it's a sensitive snowflake or
# something.
# - Closing/Truncation of barracudavpn's input/output streems seems to
# cause it to destory the tunnel, so the `script` command shouldn't
# terminate.
# - barracudavpn prints the clear text server password in its verbose
# output, so the logfile needs to be truncated/edited ASAP.
# - some sed/grep search patterns should not match themselves as `scripts`
# puts them in log
script "$logpath" --append --force --flush --command "
    clean_bcvpn() { 
        sudo barracudavpn -p
        sudo chmod a+r /etc/resolv.conf
        printf 'About to run these commands:\\n--->>>\\n%s\\n<<<--- end\\n' \"\$cmds\"
    }
    trap clean_bcvpn EXIT
    clean_bcvpn
    sudo barracudavpn --verbose --start --config '/home/jan/.config/yadmdotfiles/cuda/barracudavpn' --login 'jbischko' --serverpw '$serverpw'
    if ! grep -Eq 'Tunnel read[y]' '$logpath'; then
        echo 'Error: barracudavpn did not respond with ready tunnel' 1>&2
        exit 1
    fi
    cmds=\$(
        sed -n '/Connect state No error\./,$ p' '$logpath' |
            sed -n -E 's/^executing:\\s*([A-Za-z0-9 .\\/]+).*$/sudo ip \\1;/p'
    )
    echo > '$logpath'  # earliest we can truncate the logs
    printf 'About to run these commands:\\n--->>>\\n%s\\n<<<--- end\\n' \"\$cmds\"
    eval \"
        \$cmds
    \"
    cmds=''
    while true; do printf '%(%H:%M:%S)T ' -1; sleep 8; done &
    eval \"\${final_cmd:-ping -i 8 10.17.6.120;}\" ||
        sleep infinity  # keep i/o-streams open or barracudavpn will soil itself

    # cleanup?
    cmds=\$(
        sed -n '/Flushing VPN routes tun/,$ p' '$logpath' |
            sed -n -E 's/^executing:\\s*([A-Za-z0-9 .\\/]+).*$/sudo ip \\1;/p'
    )
"


# Cleanup
# sudo ip l s down dev tun0
# sudo ip a flush dev tun0
