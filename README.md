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
# export TMPSH=y
$HOME/.local/bin/yadm clone 'https://github.com/con-f-use/yadmdotfiles.git' --bootstrap
#$HOME/.local/bin/yadm config local.class Home # Cuda UIBK
scp conserve:bin/binary/* ~/.config/yadmdotfiles/bin/
bashitall
```

## To Do

 - Use Bash-it for modularizing aliases (once the [custom feature](https://github.com/Bash-it/bash-it/pull/1005) is done)

