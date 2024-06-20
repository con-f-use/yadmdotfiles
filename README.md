# yadmdotfiles

My dotfiles managed with [yadm](https://github.com/TheLocehiliosan/yadm).
~~Used on Ubuntu 16.04, 17.04, 17.10, 18.04, 19.10 and manjaro.~~ NixOS 23.05.

> :warning: They are an absolute Lovecraftian mess of ancient horror and new technology.
> Use them as a cautionary tale, not an example and generally don't copy and run random stuff from the internet! :warning:

 - [Install yadm](https://thelocehiliosan.github.io/yadm/docs/install#ubuntu)
 - [Templating](https://thelocehiliosan.github.io/yadm/docs/alternates)
 - [Encryption](https://thelocehiliosan.github.io/yadm/docs/encryption)
 - [Manual](https://github.com/TheLocehiliosan/yadm/blob/master/yadm.md)

## Tipps

### Install latest version

```
curl --create-dirs -fLo "$HOME/.local/bin/yadm" "https://github.com/TheLocehiliosan/yadm/raw/master/yadm" && 
    chmod a+x "$HOME/.local/bin/yadm"
# export TMPSH=y
$HOME/.local/bin/yadm clone 'https://github.com/con-f-use/yadmdotfiles.git' --bootstrap
#$HOME/.local/bin/yadm config local.class Home # Cuda UIBK
scp conserve:bin/binary/* ~/.config/yadmdotfiles/bin/
```
