#!/bin/bash
# encoding: UTF-8, break: linux, indent: 4 spaces, lang: bash 3+/eng
description="./$0 -h | [filename]
Generate a template for bash scripts.

date: May 13, 2019
author: confus <con-f-use@gmx.net>"

default_filename=/dev/stdout

libfile="$HOME/.config/yadmdotfiles/bash/jcgb.bash"
[ -r "$libfile" ] &&
    source "$libfile" ||
    { 2>echo "Requires '$libfile'!"; exit 1; }

main() {
filename=${1:-$default_filename}
cat - > "$filename" <<- EndHereDoc
#!/bin/bash
# encoding: UTF-8, break: linux, indent: 4 spaces, lang: bash 3+/eng
description="./\$0 -h | [args...]
Here goes a nice description

date: $(LANG=en_US date)
author: ${FULL_NAME:-${USER:-}} <${USER_EMAIL:-a.b@c.de}>"

libfile="\$HOME/.config/yadmdotfiles/bash/jcgb.bash"
[ -r "\$libfile" ] &&
    source "\$libfile" ||
    { 2>echo "Requires '\$libfile'!"; exit 1; }

main() {
    find "\$@" -maxdepth 2 -iname "*practice*.md" -print0 2>/dev/null |
        while IFS= read -r -d \$'\0' itm; do
            echo "I found: '\$itm'"
        done
}

if [ "\$0" = "\$BASH_SOURCE" ]; then
    usage "\$@"
    main "\$@"
fi
EndHereDoc
if [ -f "$filename" ]; then
    chmod +x "$filename"
    xdg-open  "$filename" || true
fi
}

if [ "$0" = "$BASH_SOURCE" ]; then
    usage "$@"
    main "$@"
fi
