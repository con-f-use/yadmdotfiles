#!/bin/bash
# encoding: UTF-8, break: linux, indent: 4 spaces, lang: bash 3+/eng
description="./$0 -h | [<github_user=con-f-use> [<url_type=ssh_url>]]
Lists the clone links of all repos for a given github user.

<url_type> can either be "ssh_url" (these usually starts with git@github.com and
are the default) or 'clone_url' (beginning with `https://`).

date: Mon May 13 11:24:11 CEST 2019
author: Jan Christoph Bischko <jbischko@barracuda.com>"

libfile="$HOME/.config/yadmdotfiles/bash/jcgb.bash"
[ -r "$libfile" ] &&
    source "$libfile" ||
    { 2>echo "Requires '$libfile'!"; exit 1; }

main() {
    usr=${1:-con-f-use}
    url_type=${2:-ssh_url}  # clone_url for https link
    case $url_type in
        clone_url)
            needle='https:\/\/'
        ;;
        ssh_url)
            needle='git@'
        ;;
    esac
    url="https://api.github.com/users/$usr/repos"  # ?page=1&per_page=100
    nfo "$url"
    curl -s "$url" |
        sed -E -e "/$url_type/!d; s/.*\"($needle.*)\".*/\1/"
}

if [ "$0" = "$BASH_SOURCE" ]; then
    usage "$@"
    main "$@"
fi
