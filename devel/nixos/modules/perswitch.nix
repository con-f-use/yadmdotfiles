{
  self,
  config,
  lib,
  pkgs,
  ...
}:
{
  options.services.perswitch = {
    enable = lib.mkEnableOption "Custom periphery power switch";
  };
  config = lib.mkIf config.services.perswitch.enable {
    services.udev.extraRules = ''
      # USBasp Programmer
      ACTION=="add", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05dc", GROUP="dialout", MODE="0660"
    '';
    environment.systemPackages = [ pkgs.perscom ];
  };
}
