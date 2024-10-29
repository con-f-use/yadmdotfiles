{ lib, config, ... }:
{
  imports = [ ./options.nix ];

  # config = lib.mkIf (config.veil != { }) {
  #   system.activationScripts.veil = ''
  #   '';
  # };
}
