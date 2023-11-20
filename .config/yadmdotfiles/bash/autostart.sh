#!/usr/bin/env bash
export PASSWORD_STORE_DIR=/home/jan/.config/password-store/
export GTK_THEME=Arc-Dark
[ -f "/tmp/inaust_env.txt" ] ||
    env > /tmp/inaust_env.txt

waitforwin() {
    cmd=${1:?Needs command as first argument}
    search=${2:?Needs search string as second argument (dash '-' for same as command)}
    shift 2

    if [ "$search" = "-" ]; then search="$cmd"; fi
    $cmd "$@" &
    echo "Waiting for application to start..."
    for x in {15..1}; do
        echo "$x retries left"
        sleep 1
        if wmctrl -l -x | grep -Fi "$search"; then
           sleep 1
           return
        fi
    done
}

while ! PERScom 2 2 on; do sleep 2; done &  # wait for perswitch

instantwmctrl animated 1  # turn off window manager animations
while ! xrandr | grep -E "Virtual\S?2\s+connected"; do sleep 1; done  # Wait for second monitor
xrandr \
    --output Virtual-1 --mode 3440x1440 --pos 0x0 --rotate normal --primary \
    --output Virtual-2 --mode 2560x1440 --pos 3440x0 --rotate normal
instantwmctrl focusmon

instantwmctrl tag 1
waitforwin Discord -
sleep 4

instantwmctrl tag 2
waitforwin slack -

instantwmctrl tag 3
waitforwin signal-desktop signal

instantwmctrl tag 4
waitforwin thunderbird -

instantwmctrl tag 5
waitforwin kitty -

instantwmctrl focusmon
instantwmctrl tag 1
waitforwin zoom -
# https://superuser.com/questions/1601594/how-to-start-zoom-in-background
# xdotool windowminimize "$(wmctrl -l | grep -Fi zoom | tail -n1 | cut -d ' ' -f 1)" # 2>&1 >/dev/null

firefox &
instantwmctrl layout tcl

iconf -i noanimations || instantwmctrl animated 3  # re-enable animations if configured
