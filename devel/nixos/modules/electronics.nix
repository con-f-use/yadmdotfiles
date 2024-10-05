{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.roles.electronics = {
    enable = lib.mkEnableOption "For when one dabbles in the electron";
  };
  config = lib.mkIf config.roles.electronics.enable {

    services.udev.extraRules = ''
      # USBasp programmer
      SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05dc", MODE="0660", TAG+="uaccess"
    '';
    # uaccess: devices; udisks: storage devices; ????: input (hid) and display devices (dri)
    # see: https://wiki.archlinux.org/title/udev#Allowing_regular_users_to_use_devices

    environment.systemPackages = with pkgs; [
      #kicad-unstable
      #kicad
      openscad
    ];
  };
}
