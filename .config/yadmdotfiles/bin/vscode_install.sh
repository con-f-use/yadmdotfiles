#!/bin/bash
# encoding: UTF-8, break: linux, indent: 4 spaces, lang: bash 3+/eng
description="./$0 -h | [args...]
Here goes a nice description

date: Sun Sep 15 15:13:16 CEST 2019
author: Jan Christoph Bischko <a.b@c.de>"

libfile="$HOME/.config/yadmdotfiles/bash/jcgb.bash"
[ -r "$libfile" ] && source "$libfile" || { 2>echo "Requires '$libfile'!"; exit 1; }

install_vscode() {
    local cfgfile="$HOME/.config/Code/User/settings.json"
    local gistid=737ec1dceb25ed3af09aa1be5ca2640d

    sudo apt install software-properties-common apt-transport-https wget
    wget -q https://packages.microsoft.com/keys/microsoft.asc -O- |
        sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"
    sudo apt update
    sudo apt install code
    code --install-extension shan.code-settings-sync
    echo "Gist-ID: $gistid"

    "sync.gist": "737ec1dceb25ed3af09aa1be5ca2640d",
    pip3 install --user jsoncomment
    python3 -c "if True: #indent
    import jstyleson

    filename, gistid = '$cfgfile', '$gistid'

    with open(filename) as fh:
        data = jstyleson.load(fh)

    if data.get('sync.gist') != gistid:
        data['sync.gist'] = gistid
        with open(filename, 'w') as fh:
            jstyleson.dump(data, fh)
    "
}



if [ "$0" = "$BASH_SOURCE" ]; then
    usage "$@"
    install_vscode "$@"
fi
