Bash Scripts - best practices
=======

 - Variable names should be lower snake case (e.g. `local_long_name`) unless
   globals or exported to environment
 - Do not use single- or double-letter variables. They are hard to change
   with a simple search&replace and hard to search for
 - Avoid global variables (as a general rule)
 - Use long options:
   ```
   readlink --canonicalize  # instead of readlink -f
   ```
   While `readlink -f` if fine for speed in an interactive session, it is not
   so much in a script
 - Exit on error by default if any command fails by putting `set -o errexit`
   at the beginning. Commands that are allowed to fail, can have `|| true` behind them or other error handling.
 - Exit with failure when accessing undeclared variables: `set -o nounset`.
   It you want to use something that is potentially undeclared, do it like this: 
   `if [ "${name:-defaultname}" == "Chris" ]`
 - Exit with failure, when the source command in a pipe fails:
   `set -o pipefail`,  e.g. in `mysqldump | gzip`
 - Whenever there is the sligtest chance, there might be a newline, space or
   other character special to bash in a variable, quote it.
   `rm -f "$myfile"   # instead of: rm -f $myfile`
   some joker might set `myfile="-r /home"`
   Conditionals like `[ "$name" == "Chris" ]` will give an error without the quotes if the variable doesn't exist,
   even if `nounset` was *not* declared
 - Use curly brackets around variable names it they are directly in front
   of a character allowed in variable names
   ```
   rm "$myvar"            # ok!
   rm "$myvar_old.txt"    # probably not what you think
   rm "${myvar}_old.txt"  # does what you think
   ```
   the latter would delete ".txt" unless a variable called "myvar_old" existed
 - Use the `-print0`  option if possible, when you loop over output
   of a command, e.g.
   ```
   arr=()
   find . -iname "*somefile.bin" -print0 | 
     while IFS= read -r -d $'\0' itm; do
        arr+=("$itm")
     done
   ```
   Keep in mind that the pipe to `while` in the example above creates an implicit
   subshell. Therefore `arr` remains empty even after the loop has run. 
   Sometime that is what you want, sometimes you want to change a variable in the
   parent scope:
   ```
   while IFS= read -r -d $'\0' itm; do
       arr+=("$itm")
   done < <(find . -iname "*somefile.bin" -print0)
   ```
 - Use `./*` when globbing since filenames can start with a `-` and be
   interpreted as options.
   Let's say the contents of the current directory is:
   ```
   ls $(pwd)
   # -f  -r  somedir  somefile
   ```
   then this deletes almost everything in the directory by force:
   ```
   rm *    # expands to rm -v -f -r somedir somefile
   ```
   as opposed to:
   ```
   rm ./*
   ```
   - Use quotes with `@` when you loop over arrays:
   ```
   arr=("one item" bla)
   for itm in "${arr[@]}"; do echo "$itm"; done
   # one item
   # bla
   for itm in ${arr[@]}; do echo "$itm"; done
   # one
   # item
   # bla
   ```
   Note how, without quotes, foo and bar aretreated as separate entries,
   because the space is in `$IFS` (item separators).
 - Break up long lines at logical positions for better readability:
   ```
   path=$(
      readlink --canonicalize "$(pwd)" |
          sed 's/bla/blubb'
   )
   find "$path" -mindepth 1 -maxdepth 1 -type d -not -path '*/\.*' -print0 |
       while IFS= read -r -d $'\0' itm
       do
         sed -i$() -e '/^[    ]*1[    ]/d')" ||
           {
             1>&2 echo "Error: sed error that has a very long description"   \
                       "that is totally unbroken, moving from topic to topic"\
                       "so that no one has a change to read it because it's" \
                       "really quite hypnotic."
             exit 1
           }
       done
   ```
   reads better than:
   ```
   path=$(readlink --canonicalize "$(pwd)" | sed 's/bla/blubb')
   find . -mindepth 1 -maxdepth 1 -type d -not -path '*/\.*' -print0 | while IFS= read -r -d $'\0' itm; do sed -i$() | sed -e '/^[    ]*1[    ]/d')" || { 1>&2 echo  "Error: sed error that has a very long description that is totally unbroken, moving from topic to topic so that no one has a change to read it because it's really quite hypnotic."; exit 1 }; done
   ```
   Note that you don't need backslashes behind pipes, things like `||`.
 - Double square brackets make conditionals a little saner
   ```
   if [ -f "$file1" -a \( -d "$dir1" -o -d "$dir2" \) ] # what?
   if [[ -f $file1 && ( -d $dir1 || -d $dir2 ) ]]       # a little better
   ```
   With double square brackets you don’t need to escape parenthesis and unquoted 
   variables work just fine even if they contain spaces (meaning no word splitting 
   or glob expansion).
 - Keep your lines at a length of below 80 characters.
   While not necessary or even annoying in scripts that are written with modern
   IDEs, you will often want to view your bash script in a small terminal,
   probably through SSH and lines <80 chars makte that easier.
 - Use bash built-ins rather then external commands, whenever possible
   ```
   [[ $myvar ~= ^foo ]] && echo "Starts with foo"
   ```
   rather than:
   ```
   grep -q "^foo" <<< "$myvar" && echo "Starts with foo"
   ```
 - Use modern subshell syntax rather than backticks, because it can be
   nested:
   ```
   ls "$(readlink -f $(pwd))"   # will work
   ls `readlink -f `pwd``       # nope!
   ```
 - This syntax
   ```
   my_func() {
      ...
   }
   ```
   is more concise than:
   ```
   function my_func() {
      ...
   }
   ```
 - Declare variables readonly:
   ```
   readonly __dir="(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
   ```
 - Be aware of your current directory, in general but especially, when
   including other files:
   ```
   readonly ABSOLUTE_BINPATH="$(readlink --canonicalize  "$(dirname "$0")")"
   # ... code with a lot of `cd` commands
   source "${ABSOLUTE_BINPATH}/../shared/some_functions.bash"
   ```
 - Bash has a number of linters, e.g.
   [shellcheck](https://www.shellcheck.net/)
 - Put all code in a function, so you can source your file and call it from
   within another bash script, i.e.:
   ```
   main() {
      echo "Hello world"
   }

   [ "$0" == "$BASH_SOURCE" ] &&
      main "$@" # If called as a script
   ```
 - Consider using `local` unless there a good reason for `declare`, e.g. when 
   intentionally setting an outer scope variable
 - `export varname` makes the variable available in all subshells and calls
   that are **below** the current scopte in the hirarchy
 - Don't use
   [obsolete syhntax](http://wiki.bash-hackers.org/scripting/obsolete)
 - Revert "permanent" changes. E.g. by undoing `shopt` as soon as possible
 - Avoid temporary files where you can. Good strategies:
   ```
   diff <(wget -O - "$url1") <(wget -O - "$url2")

   somevar="$(command)"
   grep -F "needle" <<<"$somevar"

   ssh server <<'EndOfHereDoc'
   cd
   for itm in {Archer,Pike,Kirk,Picard,Sisco,Janeway,Georgiou,Lorca}; do
       echo "Captain $itm" >> nerdsnipe.txt
   done
   EndOfHereDoc

   echo "Multiline
   is okay
   but any indentation
   will be included"
   ```
 - Use `mktemp` for temporary files. Among other things it ensures that you do not 
   accidentally overwrite names. Always delete them, to avoid clogging
   up the memory with repeated usage of your script. The `trap` commad is
   a good option for that:
   ```
   scratch=$(mktemp -d -t tmp.XXXXXXXXXX)
   trap "rm -rf '$scratch'" EXIT ERR  # ensure deletion on exit or failure
   # ...more code...
   ```
 - If you use non-standard commans, you should check for their existance:
   ```
   command -v ncdu &>/dev/null || {
      1>&2 echo "Error: ncdu not installed"
      exit 1
   }
   ```
 - For executable scripts, being the with a help variable, that can be
   printed. For library scripts, begin them with a discriptive comment.
   Both should contain date and the author's contact info.
 - Do as I say, not as I do. Not all examples in this document follow
   all the points in here, but that does not mean its correct or you should
   ignore them.
   Also use your head, your situation and requirements might be special, or
   this document might be wrong in some places.



Notes
=====

 - **`#!/usr/bin/env bash` vs. `#!/bin/bash`**: The main advantage of `env` is
   that it uses the default version of the interpreter rather than a hardcoded
   version. The `env` command is mainly used for python. With python, you have
   both, version 2.7 and 3.X installed AND used on most systems. The `env`
   syntax comes into play when you want to run your python script with whatever
   is the default on you current system EXPLICITLY. If you python script can
   only run on 2.7, you would almost always hardcode '#!/usr/bin/python2.7'.
   With bash the hardcoded '#!/bin/bash' is probably what you want.


Template
========

```
#!/bin/bash
# coding: UTF-8, break: linux, indent: 4 spaces, lang: bash 4+/eng
description="$0 [args...]
Here goes a little description.

date: Nov 5, 2018
author: John Doe <jdoe@gmail.com>"

[[ "${DEBUG^^}" =~ ^(1|Y(ES)?|ON|T(RUE)?|ENABLE(ED)?)$ ]] &&
    set -o xtrace
set -o nounset
set -o errexit
set -o pipefail

main() {
    find "$@" -maxdepth 1 -iname "*practice*.md" -print0 |
      while IFS= read -r -d $'\0' itm; do
          echo "I found: '$itm'"
      done
}

for itm in "$@"; do
[[ $itm =~ ^(-h|--help|-help|-\?)$ ]] &&
    { >&2 echo "Usage: $description"; exit 0; }
done

[ "$0" = "$BASH_SOURCE" ] &&
    main "$@"

```

Links
=====
- http://wiki.bash-hackers.org/scripting/newbie_traps
- https://google.github.io/styleguide/shell.xml
