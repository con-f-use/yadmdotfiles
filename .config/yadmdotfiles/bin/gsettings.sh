#!/bin/bash

### Screensaver/Power management/Animations
gsettings set org.gnome.desktop.screensaver ubuntu-lock-on-suspend false
gsettings set org.gnome.desktop.screensaver idle-activation-enabled false
gsettings set org.gnome.settings-daemon.plugins.power active false
gsettings set org.gnome.desktop.lockdown disable-lock-screen true
gsettings set org.gnome.desktop.screensaver lock-delay 0
gsettings set org.gnome.settings-daemon.plugins.orientation active false
#gsettings set org.gnome.desktop.session idle-delay 3600
#gsettings set org.gnome.settings-daemon.plugins.orientation active false'

# Print shortcut
if [ "$(gsettings get org.gnome.settings-daemon.plugins.media-keys screenshot)" == "'Print'" ] && [ "$(gsettings get org.gnome.settings-daemon.plugins.media-keys area-screenshot-clip)" == "'<Ctrl><Shift>Print'" ]; then
    gsettings set org.gnome.settings-daemon.plugins.media-keys area-screenshot-clip 'Print'
    gsettings set org.gnome.settings-daemon.plugins.media-keys screenshot '<Ctrl><Shift>Print'
fi
