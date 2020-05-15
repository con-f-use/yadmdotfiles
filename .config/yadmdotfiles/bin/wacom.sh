#!/bin/sh
# https://wiki.archlinux.org/index.php/Wacom_tablet#Reducing_the_screen_area_width

# Setting that seems to wrok well for my PTK-640
xsetwacom set "Wacom Intuos4 6x9 Pen stylus" MapToOutput 1000x475+0+0
