{ config, lib, pkgs, ... }:
let
    mypackages = import ../packages { pkgs=pkgs; };
in {
options.services.perswitch = {
  enable = lib.mkEnableOption "Custom periphery power switch";
};
config = lib.mkIf config.services.perswitch.enable {

  services.udev.extraRules = ''
    ACTION=="add", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05dc", GROUP="dialout", MODE="0660"
  '';

  environment.systemPackages = [ mypackages.perswitch.perscom ];

}; }

