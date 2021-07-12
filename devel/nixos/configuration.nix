{ config, lib, pkgs, ...}:
{
  imports = [
    #./machines/hplap.nix
    ./machines/workstationplayer.nix
  ];
}
