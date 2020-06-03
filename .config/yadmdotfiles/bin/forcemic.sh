#!/bin/sh

# pacmd list-sources | grep "name:"
mic_name=alsa_input.usb-Blue_Microphones_Yeti_Stereo_Microphone_REV8-00.analog-stereo

while true; do 
    pacmd set-source-volume "$mic_name" 65535
    sleep 0.1
done

