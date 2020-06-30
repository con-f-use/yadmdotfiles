#!/bin/bash

### Gnome shell extensions
gv=$(gnome-shell --version | cut -d' ' -f3)
base_url="https://extensions.gnome.org"

install_requirements() {
    sudo apt-get install -y chrome-gnome-shell gnome-tweak-tool
}

get_dl_link () {
    info_url="${base_url}/extension-info/?pk=${1}&shell_version=${gv}"
    echo "${base_url}$(curl "$info_url" |
        sed -e 's/.*"download_url": "\([^"]*\)".*/\1/')"
}

install_gsext () {
    # args: the uuid to download to
    temp=$(mktemp -d)
    uuid="$1"
    url=$(get_dl_link "$uuid")
    dest="$HOME/.local/share/gnome-shell/extensions/$uuid"

    echo "uuid: $uuid"
    echo "dest: $dest"
    echo "url: $url"

    trap "rm -rfv $temp" EXIT
    curl -L "$url" > "$temp/e.zip"
    unzip "$temp/e.zip" -d "$dest"
    rm -rfv "$temp"
    trap '' EXIT

    gnome-shell-extension-tool --enable-extension="$uuid"
}

if [ "$0" = "$BASH_SOURCE" ]; then
    # 15 alternate tab, 28 gtile, 294 shellshape, 517 caffeine, 685 redshift
    # 750 openweather, 779 clipboard indicator, 826 suspend button, 1238 time++
    # 120 system monitor

    for uuid in 15 28 517 750 779 826 1238; do
        install_gsext "$uuid"
    done
fi
