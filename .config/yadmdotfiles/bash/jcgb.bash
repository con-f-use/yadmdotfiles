#!/bin/bash

getbool() {
    local in="${1:-no}"
    if [[ "${in^^}" =~ ^(1|Y(ES)?|ON|T(RUE)?|ENABLE(ED)?)$ ]]; then
        return 0
    fi
    return 1
}

usage() {
    local DEBUG=${DEBUG:-N}
    if [[ "${DEBUG^^}" =~ ^(1|Y(ES)?|ON|T(RUE)?|ENABLE(ED)?)$ ]]; then
        set -o xtrace
        shopt -s shift_verbose
    fi
    if [ -z ${NO_STRICT+x} ]; then
        set -o errexit -o nounset -o pipefail
    fi

    for itm in "$@"; do
    if [[ "$itm" =~ ^(-h|--help|-help|-\?)$ ]]; then
        1>&2 echo "Usage: $description"; exit 0;
    fi
    done
}


add_to_file () {
    local priv=""
    if [ ! -w "$1" ]; then
        priv="sudo "
    fi
    if $priv grep -oqF "$2" "$1" &>/dev/null; then return; fi
    echo | $priv tee -a "$1" >/dev/null
    echo "$2" | $priv tee -a "$1" >/dev/null
    while read -r line; do
        echo "$line" | $priv tee -a "$1" >/dev/null
    done
}


usr_confirm () {
    # Usage:
    #   usr_confirm "Do you even? [Y/n]" [timeout_in_seconds] [answer_on_timeout]
    #
    local answers="$(expr match "$1" '.*\[\([NnYy]/[NnYy]\)\]')"
    if [ -z "$answers" ]; then
        err Answer string missing.
    fi
    local "empty=$(expr match "$answers" '.*\([YN]\)')" # default on enter
    if [ -z "$empty" ]; then
        empty=N
    fi
    local tout="${2:-}"    # length of timeout
    if [ ! -z "$tout" ]; then tout="-t$tout"; fi
    local tmout="${3:-N}"  # default on timeout?
    if [[ -t 0 ]]; then
        read $tout -n 1 -p "$1 " do_it ||
            do_it="$tmout"
    fi
    echo
    if [[ $do_it =~ ^(y|Y)$ ]]; then
        return 0
    fi
    if [ -z "$do_it" ] && [ "$empty" != "N" ]; then
        return 0
    fi
    return 1
}


_msg() {
    echo -en "[$1: $(date '+%y-%m-%d %H:%m:%S %:::z')\e[0m]: "; echo "$2"; }
dbg() { if getbool "${DEBUG:-no}"; then 1>&2 _msg "\e[34mDebug" "$*"; fi }
nfo() { _msg "\e[32mInfo " "$*"; }
wrn() { _msg "\e[33mWarn " "$*"; }
err() {
    last="${@:$#:$#}"
    code=$([[ "$last" =~ [0-9]+ ]] && echo "$last" || echo 1)
    1>&2 _msg "\e[31mError" "${*%%$code}"
    exit $code
}


if [ "$0" = "$BASH_SOURCE" ]; then
    usr_confirm "Answer my question? [N/y]" 5 && echo yes || echo no
    dbg This should not be shown
    DEBUG=y dbg This should be shown
    nfo This is an info
    wrn test
    err "This is a library and not meant for executing."
fi
