{ config, lib, pkgs, ... }:

{
options.roles.electronics = {
  enable = lib.mkEnableOption "For when one dabbles in the electron";
};
config = lib.mkIf config.roles.electronics.enable {

  services.udev.extraRules = ''
    # USBasp programmer
    ACTION=="add", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="05dc", GROUP="dialout", MODE="0660"
  '';

  environment.systemPackages = with pkgs; [
    #kicad-unstable
    #kicad
    openscad
  ];
}; 
}

