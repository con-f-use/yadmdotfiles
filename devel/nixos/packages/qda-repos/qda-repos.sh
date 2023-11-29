#!/usr/bin/env bash

folsom_url='ssh://git@folsom.ngdev.eu.ad.cuda-inc.com:7999'
folsom=(
    autotest
    autoweasel
    cudadevpi
    cudasetuptools
    jenkins-files
    jenkins-libraries
    python-ci
    qa-pypackage
    qanix
    qda_rest
    qda_util
    vault-things
)

stash_url='ssh://git@stash.cudaops.com:7999'
stash=(
    autotest-dockerfiles
    docker-registry
    dockerfiles-general
    weasel
    webservices
)

clone() {
    url=${1?need clone-url as first parameter}
    repo=${2?need repo name as second paramerter}
    target="$HOME/devel/cuda"
    echo ------ $repo ------
    if [ -d "$target/$repo" ]; then
        git -C "$target/$repo" fetch --all
        git -C "$target/$repo" fetch --tags
    else
        git clone --bare "$url" "$target/$repo/"
    fi
    echo; echo
}
export -f clone

main() {
    for repo in "${folsom[@]}"; do
        parallel --semaphore --jobs +4 clone "$folsom_url/BNNGA/$repo" "$repo" ';' echo "$repo" done.
    done
    parallel --semaphore --wait

    for repo in "${stash[@]}"; do
        parallel --semaphore --jobs +4 clone "$stash_url/BNNGA/$repo" "$repo" ';' echo "$repo" done.
    done
    parallel --semaphore --wait

    clone "$stash_url/~jbischko/folsom_migration.git" folsom_migration
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
    main "$@"
fi

