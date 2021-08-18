#!/usr/bin/env bash
# encoding: UTF-8, break: linux, indent: 4 spaces, lang: bash 4+/eng
description="./$0 -h | shortcuts | expansions | manipulations | arrays | dictionaries
Some git helpers, e.g. to revert commits (history rewrite-sytle).

date: Tue 06 Jul 15 13:54:56 CEST 2021
author: confus <con-f-use@gmx.net>"

libfile="$HOME/.local/lib/jcgb/jcgb.bash"
[ -e "$libfile" ] || curl --insecure --create-dirs --output "$libfile" 'https://gist.githubusercontent.com/con-f-use/7914e4896f615b926eef63b4739e993f/raw/8c343944e760c0d26cce55a2f1eaf06ddcf257cb/jcgb.sh' || { 2>echo "Requires '$libfile'!"; exit 1; }
source "$libfile"

cmd:s() { cmd:shortcuts "$@"; }
cmd:shortcuts() {
echo 'In statistical order; most used to least used:
    Ctrl + r             reverse history search
    Alt  + .             Repeat last word
    Ctrl + d             Logout

    Ctrl + a / e         Go to the start / end of the command line
    Ctrl + u / k         Cut everything left / right of cursor
    Alt  + b / f         Move cursor one word left / right
    Ctrl + w / Alt + d   Cut word left / right of the cursor
    Ctrl + y             Paste previously cut contents

    Alt  + t             Swap the two words under the curor (bash)
    Ctrl + t             Swap the two characters under the cursor
    Ctrl + x Ctrl + e    Edit long line in editor
    Ctrl + l             Clear screen

    Ctrl + x             Glob expand a word
    Alt + Ctrl + e       Shell-expand line

    !$                   Last non-command argument
    !^                   First non-command argument
    !*                   All non-command arguments
    ^foo^bar             Replace foo by bar in last command'
}

cmd:e() { cmd:expansions "$@"; }
cmd:expansions() {
echo '${p<operator>w} substittutes/assigns:
    operator    p set & not null    set & null    unset
    :-                p             w             w
    -                 p             null          w
    :=                p             =w            =w
    =                 p             null          =w
    :?                p             err&exit      err&exit
    ?                 p             null          err&exit
    :+                w             null          null
    +                 w             w             null'
}

cmd:m() { cmd:manipulations "$@"; }
cmd:manipulations(){
echo '
    ${foo-default}            # value of foo or the string "default" if no foo
    ${foo/bar/rab/}           # replace first occurance of "bar" by "rab" in foo
    ${foo//bar/rab/}          #  same but for all occurances of "bar"
    ${foo%/*}                 # delete globbed match from the right, non-greedy: usr/local/share/ca-certificates --> usr/local/share
    ${foo%%/*}                #  same as above but greedy: usr/local/share/ca-certificates --> usr                 
    ${foo##*/}                #  same but from left greedy: usr/local/share/ca-certificates --> local/share/ca-certificates
    ${foo#*/}                 #  same but non-greedy: usr/local/share/ca-certificates --> ca-certificates
    ${foo#usr/local/share/}   #  same without globbing: usr/local/share/ca-certificates --> ca-certificates
    ${#foo}                   # length of the string value of foo (same as for arrays, slicing works as well)
    ${!foo*}                  # expands to all variable names that are declared and start with "foo"

    echo bl{a,b,c{d,e}}{x,y}  # expands to: blax blay blbx blby blcdx blcdy blcex blcey'
}

cmd:a() { cmd:arrays "$@"; }
cmd:arrays() {
echo '
    declare -a arr=("element1" element2 'element3' ...)   # Declare & init array, init-part "=(element..." optional
    ${arr[@]}                # Whole array as string
    ${#arr[@]}               # Number of elements in the array
    ${arr[@]:3:2}            # Elements in the 3rd index and fourth index
    ${#arr}                  # Number of characters in the first element of the array
    ${#arr[n]}               # Number of characters in the n-th element of the array
    ${arr[n]:3:2}            # Characters in the 3rd and 4th index of the n-th element
    ${arr[@]/element2/ah}    # Replace "element2" by "ah" in the whole array without changing the array
    arr=("${arr[@]}" "AIX" "HP-UX") # Add elements to array
    copy=("${arr[@]}")       # Copy an array
    unset arr                # Delete an array
    unset ${arr[n]}          # ...or element
    arr=( $(cat file) )      # Load file line-wise into array
    arr+=(b c d)             # Extend array with other array
    for v in "${arr[@]}"; do echo "$v"; done # Loop over elements'
}

cmd:d() { cmd:dictionaries "$@"; }
cmd:dictionaries() {
cmd:arrays
echo '
Mostly similar to regular arrays (above)...
    declare -A arr=( ["foo"]=bar ['bla']="laber" [herp]=derp )   # Declare & init array, init-part "=(element..." optional
    ${arr[*]}         # All of the items in the array
    ${!arr[*]}        # All of the indexes in the array
    ${#arr[*]}        # Number of items in the array
    [ ${arr[foo]+_} ] && echo "Found key" # Test if key is there
    for k in "${!arrr[@]}"; do echo "$k" "${arr[$k]}"; done # Loop over elements and values'
}

cmd:main() { cmd:shortcuts; }

if [ "$0" = "$BASH_SOURCE" ]; then
    subcommand "$@"
fi
