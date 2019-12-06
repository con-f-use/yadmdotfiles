# yadmdotfiles
My dotfiles managed with [yadm](https://github.com/TheLocehiliosan/yadm).
Used on Ubuntu 16.04, 17.04, 17.10, 18.04, 19.10 and manjaro.

 - [Install yadm](https://thelocehiliosan.github.io/yadm/docs/install#ubuntu)
 - [Templating](https://thelocehiliosan.github.io/yadm/docs/alternates)
 - [Encryption](https://thelocehiliosan.github.io/yadm/docs/encryption)
 - [Manual](https://github.com/TheLocehiliosan/yadm/blob/master/yadm.md)
 - [Bash-it](https://github.com/Bash-it/bash-it)
 - [Liquidprompt](https://github.com/nojhan/liquidprompt)

## Tipps

### Install latest version

```
sudo apt-get install -y git git-lfs pass curl
curl --create-dirs -fLo "$HOME/.local/bin/yadm" "https://github.com/TheLocehiliosan/yadm/raw/master/yadm" && 
    chmod a+x "$HOME/.local/bin/yadm"
$HOME/.local/bin/yadm clone 'https://github.com/con-f-use/yadmdotfiles.git' --bootstrap
git-gnome-keyring.sh
#~/bin/yadm config local.class Home # Cuda UIBK
yadm submodule init
yadm submodule update
exit # reload shell
git clone --recursive 'https://conserve.dynu.net/gitlab/jan/pass.git ~/.config/password-store'
# Extract keys, maybe gpg --edit-key EEF19B71F9C734D8 > trust > 5 / uniethi c0nfus gal
# curl -u "confus:$(systemd-ask-password unithi03)" "http://unethische.org/misc/ident/tmp.sh" -o tmp.sh
scp conserve:bin/binary/* ~/.config/yadmdotfiles/bin/
bashitall
```

## To Do

 - Use Bash-it for modularizing aliases (once the [custom feature](https://github.com/Bash-it/bash-it/pull/1005) is done)

