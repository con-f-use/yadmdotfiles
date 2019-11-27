#!/bin/bash
# encoding: UTF-8, break: linux, indent: 4 spaces, lang: bash 3+/eng
description="$0 [args...]
Update or clone the most used cuda-repos.

"

install_requires() {
    command -v parallel &>/dev/null ||
        sudo apt-get install parallel &&
        echo will cite | parallel --citation
}


main() {
    basedir=${1:-~/devel/cuda}
    basedir=$(readlink -f "$basedir")
    if [ ! -d  "$basedir" ]; then
        mkdir -p "$basedir"
    fi
    install_requires
    oldpwd="$(pwd)"

    for repo in bnnga/{autotest,ansible,autotest-infrastructure,webservices,jenkins-files,autotest-dockerfiles,dockerfiles-general,docker-registry,random_scripts} \
        '~jbischko/'{cudadevpi,touchmysc,cudasetuptools,ztcrypt,atdiff} \
        '~gchappell/ztdclient' \
        '~czangerle/'{cookiecutter,qa_mongoengine,qa_host_controller};
    do
        repodir="$basedir/$(basename "$repo")"
        if [ -d "$repodir/.git" ]; then
            echo -n "cd '$repodir' && git fetch --recurse-submodules && "
            echo "git pull || 1>&2 echo 'Pull failed for $repo'"
        else
            echo -n "echo '$repo does not exist, cloning...'; "
            echo -n "cd $basedir && git clone --recursive "
            echo "'ssh://git@stash.cudaops.com:7999/$repo.git' '$repodir' || 1>&2 echo 'Cone failed for $repo'"
        fi
    done | parallel --jobs 4
}

if [ "$0" = "$BASH_SOURCE" ]; then
    if [[ "${DEBUG^^}" =~ ^(1|Y(ES)?|ON|T(RUE)?|ENABLE(ED)?)$ ]]; then
        set -o xtrace
        shopt -s shift_verbose
    fi
    set -o errexit
    set -o nounset
    set -o pipefail

    for itm in "$@"; do  # handle help message
    if [[ $itm =~ ^(-h|--help|-help|-\?)$ ]]; then
        >&2 echo "Usage: $description"
        exit 0
    fi
    done

    main "$@"
fi
