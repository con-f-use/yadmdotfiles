#!/bin/bash

if ! command -v tcc &>/dev/null; then
    echo "Remark: 'tcc' not installed. Installing it now:" 1>&2
    sudo apt-get -y install tcc
fi

file="/tmp/$$-$(date +%y%m%d-%H%M%S%N)"
cat - > "$file" << EOF
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>

int main(int argc, char** argv) {
EOF

if [ -r "$1" ]; then
    cat "$1" >> "$file"
else
    echo "$1" >> "$file"

echo -e "\n return 0;\n}" >> "$file"
shift

tcc -run "$file" "$@"

rm "$file"

