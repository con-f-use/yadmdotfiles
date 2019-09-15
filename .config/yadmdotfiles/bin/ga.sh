#!/bin/bash
# Prints auth-tokes generated from a Google Authenticator database.
# Invoke with 'get' as first argument to pull the database from a rooted phone using adb.

base=$HOME/Documents/bank/ga/databases/databases
remote=/data/data/com.google.android.apps.authenticator2/databases/databases

err() { 1>&2 echo Error: "$@"; exit 1; }

command -v apt-get &>/dev/null ||
    err "Assuming debian-like system"

apti() {
    for pkg in "$@"; do
        command -v "$pkg" &>/dev/null ||
            sudo apt-get install -y "$pkg"
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
}

if [ ! -r "$base" ] || [ "$1" == "get" ]; then getdb; fi

apti sqlite3 oathtool

sqlite3 "$base" 'SELECT email,secret FROM accounts;' |
while read entry; do
    service=$(echo "$entry" | cut -d '|' -f 1)
    token=$(oathtool --totp -b "$(echo "$entry" | cut -d '|' -f 2)")
    echo -e "\e[1;33m$service\e[0m: \e[1;32m$token\e[0m"
done
