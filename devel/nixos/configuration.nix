{ config, lib, pkgs, ...}:
{
  imports = [
    ./machines/hplap.nix
  ];
}
