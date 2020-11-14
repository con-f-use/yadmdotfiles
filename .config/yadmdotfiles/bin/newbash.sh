#!/usr/bin/env bash
# encoding: UTF-8, break: linux, indent: 4 spaces, lang: bash 3+/eng
description="./$0 -h | [filename]
Generate a template for bash scripts.

date: May 13, 2019
author: confus <con-f-use@gmx.net>"

default_filename=/dev/stdout

libfile="$HOME/.local/lib/jcgb/jcgb.bash"
[ -e "$libfile" ] || curl --create-dirs --output "$libfile" 'https://gist.githubusercontent.com/con-f-use/7914e4896f615b926eef63b4739e993f/raw/66215fcfa18195d0261a3fdfe5a204da48a1ca8c/jcgb.sh' || { 2>echo "Requires '$libfile'!"; exit 1; }
source "$libfile"

main() {
filename=${1:-$default_filename}
cat - >> "$filename" <<- EndHereDoc
#!/bin/bash
# encoding: UTF-8, break: linux, indent: 4 spaces, lang: bash 3+/eng
description="./\$0 -h | [args...]
<++ Here goes a nice description>

date: $(LANG=en_US date)
author: ${FULL_NAME:-${USER:-<++>}} <${USER_EMAIL:-<++>}>"

libfile="\$HOME/.local/lib/jcgb/jcgb.bash"
[ -e "\$libfile" ] || curl --insecure --create-dirs --output "\$libfile" 'https://gist.githubusercontent.com/con-f-use/7914e4896f615b926eef63b4739e993f/raw/66215fcfa18195d0261a3fdfe5a204da48a1ca8c/jcgb.sh' || { 2>echo "Requires '\$libfile'!"; exit 1; }
source "\$libfile"

cleanup() {
    nfo "Cleaning up on interruption/error..."
    <++ cleanup operations>
}

main() {
    <++>
    # find "\$@" -maxdepth 2 -iname "*practice*.md" -print0 2>/dev/null |
    #     while IFS= read -r -d \$'\0' itm; do
    #         echo "I found: '\$itm'"
    #     done

    # Print only lines where a substitution was made with sed:
    #sed --regexp-extended --quite 's/bla(.{1,3})blubb)/\1/gp' some_file
    # Make sustition only in lines that match another pattern:
    # sed --regexp-extended '/rs(yn)c/s/<command>/1woo/g' newbash.sh

    # Common rsync options:
    #rsync --rsh=<command> --partial --append-verify --recursive \
    #  --human-readable --info=progress2 --compress source destination
}

if [ "\$0" = "\$BASH_SOURCE" ]; then
    usage "\$@"
    trap "cleanup" ERR INT # EXIT for even normal exits
    main "\$@"
fi
EndHereDoc
if [ -f "$filename" ] && [ "$filename" != "$default_filename" ]; then
    chmod +x "$filename"
    xdg-open  "$filename" &
fi
}

if [ "$0" = "$BASH_SOURCE" ]; then
    usage "$@"
    main "$@"
fi

