{ config, lib, pkgs, ... }:
let
  cfg = config.roles.networks;
in
{
  options.roles.networks = {
    enable = lib.mkEnableOption "Enable Network Manager with confus networks";
    wifi = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = "WiFi interface for pre-configured networks";
    };
    ethernet = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = "Ethernet interface for pre-configured networks";
    };
    environmentFiles = lib.mkOption {
      default = [ ];
      type = with lib.types; listOf path;
      example = [ "/var/lib/nm_secrets.env" ];
      description = ''
        Files to load as environment file. Environment variables from this file
        will be substituted into the static configuration file using [envsubst](https://github.com/a8m/envsubst).
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    let
      networks = builtins.map
        (x: import x { inherit (cfg) wifi ethernet; })
        [
          ./Aragorn.nix
          ./AsgarD.nix
          ./Basti27.nix
          ./Midgard.nix
          ./NETGEAR.nix
          ./Ragnar.nix
          ./cuda-inc.nix
          ./schregolas.nix
          ./worklap_ethernet.nix
        ];
    in
    {
      assertions = [
        {
          assertion = cfg.wifi != null;
          message = "roles.networks.wifi must be a valid interface (default: null)";
        }
        {
          assertion = cfg.ethernet != null;
          message = "roles.networks.ethernet must be a valid interface (default: null)";
        }
      ];
      networking.networkmanager.ensureProfiles.profiles = builtins.foldl' (acc: x: acc // x) { } networks;
      networking.networkmanager.ensureProfiles.environmentFiles = cfg.environmentFiles;
    }
  );
}
