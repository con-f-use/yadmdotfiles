#!/usr/bin/env bash
# Prints auth-tokes generated from a Google Authenticator database.
# Invoke with 'get' as first argument to pull the database from a rooted phone using adb.

base=$HOME/Documents/bank/ga/databases/databases
remote=/data/data/com.google.android.apps.authenticator2/databases/databases

err() { 1>&2 echo Error: "$@"; exit 1; }

apti() {

    for pkg in "$@"; do
        if ! command -v "$pkg" &>/dev/null; then
            if command -v apt-get &>/dev/null; then
                sudo apt-get install -y "$pkg"
            else
                err "Please install $pkg"
            fi
        fi
    done
}

getdb() {
    apti adb

    if [ -e "$base" ]; then
        cp "$base" "$base-$(date +%y%m%d-%H%M%S)" ||
            err "Failed to create a backup of '$base'"
    fi

    #sudo adb pull "$remote" "$base" ||
    adb shell "su -c 'cat $remote'" > "$base" ||
        err "Unable to pull '$remote'"

    echo "got db."
}

qrcodify() {
    apti sqlite3 qrencode jq

    sqlite3 "$base" 'SELECT email,secret FROM accounts;' |
    while read entry; do
        service=$(echo "$entry" | cut -d '|' -f 1)
        secret=$(echo "$entry" | cut -d '|' -f 2)
        name=$(jq -nr --arg v "$service" '$v|@uri')
        uri="otpauth://totp/$name:$name?secret=$secret&issuer=confus&algorithm=SHA1&digits=6&period=30"
        echo "$entry; sec: $secret; ser: $service"
        echo "$uri"
        qrencode -o /tmp/out.png "$uri" && xdg-open /tmp/out.png
    done
}

tok() {
    apti sqlite3 oathtool

    sqlite3 "$base" 'SELECT email,secret FROM accounts;' |
    while read entry; do
        service=$(echo "$entry" | cut -d '|' -f 1)
        token=$(oathtool --totp -b "$(echo "$entry" | cut -d '|' -f 2)")
        echo -e "\e[1;33m$service\e[0m: \e[1;32m$token\e[0m"
    done
}

if [ "$0" = "$BASH_SOURCE" ]; then
    if [ ! -r "$base" ] || [ "$1" = "get" ]; then getdb; fi
    [ "$1" = "tok" ] &&
        tok "$@"
    [ "$1" = "qr" ] &&
        qrcodify "$@"
fi
