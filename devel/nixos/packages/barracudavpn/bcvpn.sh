#!/usr/bin/env bash
err() { echo "Error: $&" 1>&2; exit 1; }

test -t 0 ||
    err 'Not in login shell!'

serverpw=$(gopass show -o Cuda/cudaws | cat)
gopass show -o Infrastructure/janpw | sudo -S true

sudo barracudavpn --verbose --start \
    --config "$HOME/.config/barracudavpn/" \
    --login "jbischko@barracuda.com" \
    --serverpw "$serverpw"

