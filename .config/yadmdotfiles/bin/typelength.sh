#!/bin/bash
# Prints the length of a given C type, e.g. long unsigned int

dir=$(mktemp -d)
file="$dir/typelength.c"

cat > "$file" <<-__EOF
    #include <stdio.h>
    #include <stdint.h>

    int main() {
        printf("%zu\n", sizeof($@));

        return 0;
    }

__EOF

if gcc "$file" -o "$dir/typelength" &> /dev/null; then
    "$dir/typelength"
else
    echo "Error: Not a C type?" 1>&2
fi

rm -r "$dir"
