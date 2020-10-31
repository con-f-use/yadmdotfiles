#!/bin/sh

screen=Virtual1
prerandr=echo
prerandr=

# modline with:   gtf 3440 1440 60
modeline="3440x1440_60.00  419.11  3440 3688 4064 4688  1440 1441 1444 1490  -HSync +Vsync"
mode="$(grep -Po '\d+x\d+(_\d+(.\d+)?)?' <<< "$modeline")"

echo "$mode"

$prerandr xrandr --newmode $modeline
$prerandr xrandr --addmode "$screen" "$mode"
$prerandr xrandr --output "$screen" --mode "$mode"
