{ config, lib, pkgs, ... }:

{
options.roles.conferencing = {
  enable = lib.mkEnableOption "Setup for video conferencing";
};
config = lib.mkIf config.roles.conferencing.enable {
  # https://wiki.archlinux.org/index.php/Udev
  # https://wiki.archlinux.org/index.php/Webcam_setup
  # v4l2-ctl --list-devices
  # 4l2-ctl -d <device> --list-ctrls
  # udevadm info --attribute-walk --name=/dev/video0

  # Logitech C270 702p Webcam
  # Bus 003 Device 005: ID 046d:0825 Logitech, Inc. Webcam C270
  #                     brightness 0x00980900 (int)    : min=0 max=255 step=1 default=128 value=128
  #                       contrast 0x00980901 (int)    : min=0 max=255 step=1 default=32 value=32
  #                     saturation 0x00980902 (int)    : min=0 max=255 step=1 default=32 value=32
  # white_balance_temperature_auto 0x0098090c (bool)   : default=1 value=1
  #                           gain 0x00980913 (int)    : min=0 max=255 step=1 default=64 value=64
  #           power_line_frequency 0x00980918 (menu)   : min=0 max=2 default=2 value=2
  #      white_balance_temperature 0x0098091a (int)    : min=0 max=10000 step=10 default=4000 value=4000 flags=inactive
  #                      sharpness 0x0098091b (int)    : min=0 max=255 step=1 default=24 value=24
  #         backlight_compensation 0x0098091c (int)    : min=0 max=1 step=1 default=0 value=0
  #                  exposure_auto 0x009a0901 (menu)   : min=0 max=3 default=3 value=3
  #              exposure_absolute 0x009a0902 (int)    : min=1 max=10000 step=1 default=166 value=166 flags=inactive
  #         exposure_auto_priority 0x009a0903 (bool)   : default=0 value=1

  services.udev.extraRules = ''
    # Webcam 
    # SUBSYSTEM=="video4linux", KERNEL=="video[0-9]*", ATTRS{product}=="HD Pro Webcam C920", ATTRS{serial}=="BBBBFFFF", ATTR{index}=="0", RUN+="/usr/bin/v4l2-ctl -d $devnode --set-ctrl=zoom_absolute=170"
  '';

  environment.systemPackages = with pkgs; [
    v4l-utils
  ];
}; 
}

