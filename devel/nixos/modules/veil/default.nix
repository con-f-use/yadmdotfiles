{ lib, config, pkgs, ... }:
{
  imports = [ ./options.nix ];

  config = lib.mkIf (config.veil != { }) {
    environment.systemPackages = [ pkgs.veil ];
  };
}
