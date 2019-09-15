#!/bin/bash
#
# Make a backup of apt-installed packages (or restore it).
#
# Usage:
#     backup-apt-pkgs.sh [file]
#     backup-apt-pkgs.sh restore [file]

LOC="$HOME/pkg-bak"
PKGS="Package.list"
SRCS="sources.list"
KEYS="Repo.keys"

if [ "$1" == "restore" ]; then
    shift
    LOC=${1:-$LOC}
    echo "Restoring packages from '$LOC'..."
    sudo -s <<- SUDOORGY
        apt-key add "$LOC/Repo.keys"
        cp -R "$LOC/sources.list"* /etc/apt/
        apt-get update
        apt-get install -y dselect
        dselect update
        dpkg --set-selections < "$LOC/$PKGS"
        apt-get dselect-upgrade -y
	SUDOORGY
else
    echo "Backup mode..."
    LOC=${1:-$LOC}
    [ -d "$LOC" ] || { mkdir -p "$LOC" || exit 1; }
    [ -z "$(ls -A "$LOC")" ] || {
        1>&2 echo "'$LOC' must be empty. Maybe do a backup and try again?"
        exit 1
    }
    dpkg --get-selections > "$LOC/$PKGS"
    sudo cp -R "/etc/apt/$SRCS"* "$LOC"
    sudo apt-key exportall > "$LOC/Repo.keys"
fi
