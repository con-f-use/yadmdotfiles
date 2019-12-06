#!/bin/bash
# Build git-credential-gnome-keyring to have git access ssh keys with 
#+passphrases stored in gnome-keyring

oldpwd=$(pwd)
gcgk=/usr/share/doc/git/contrib/credential/gnome-keyring
sudo=$(command -v sudo 2>/dev/null || echo -n "")

$sudo apt-get install 'libglib[0-9.]{0,}-dev' libgnome-keyring-dev git || exit 1

cd "$gcgk" 
$sudo make
echo "Use it with:
    git config --global credential.helper $gcgk/git-credential-gnome-keyring"
cd "$oldpwd"

