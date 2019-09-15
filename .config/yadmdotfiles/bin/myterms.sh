#! /bin/sh
# Open two maximzed side-by-side gome terminals

# Delay in ms
# Keypad number: key_value to use
# 0: 90      1: 87       2: 88
# 3: 89      4: 83       5: 84
# 6: 85      7: 79       8: 80
# 9: 81

for req in xdotool gnome-terminal; do
    command -v "$req" &>/dev/null || sudo apt install -y "$req" || exit 1
done

#subl && sleep 1 && xdotool key --delay 500 --window "$(xdotool getactivewindow)" Super+Left # Ctrl+Alt+83 on old Ubuntu
#gnome-terminal && sleep 1 &&  xdotool key --delay 500 --window "$(xdotool getactivewindow)" Super+Right # Ctrl+Alt+85 on old Ubuntu
subl && sleep 1 && xdotool key --delay 500 --clearmodifiers "Super+Left"
gnome-terminal && sleep 1 &&  xdotool key --delay 500 --clearmodifiers "Super+Right"
ssh -f -N -D 0.0.0.0:1080 conserve
