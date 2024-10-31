{ lib, config, ... }:
let
  inherit (lib) types mkOption;

  secretOptions = (with types; submodule (
    { name, ... }: # name, lib, options, config, specialArgs
    {
      options = {
        name = mkOption {
          type = with types; str;
          default = name;
          readOnly = true;
        };

        target = mkOption {
          type = with types; str;
          default = "/var/lib/secrets/${name}";
          description = ''
            Output path for the secret file.
          '';
        };

        # command = mkOption {
        #   type = with types; nullOr (listOf str);
        #   default = null;
        #   example = [ "gopass" "show" "-o" "MySystem/Mypass" ];
        #   description = ''
        #     Command to run to get the secret
        #   '';
        # };

        script = mkOption {
          type = with types; nullOr lines;
          default = null;
          example = literalExample ''
            #!/usr/bin/env bash

            gopass show -o Infrastrucutre/server |
              mkpasswd --method=SHA-512 --stdin
          '';
          description = ''
            Script to run to get the secret
          '';
        };

        # file = mkOption {
        #   type = with types; nullOr str;
        #   default = null;
        #   example =  "/etc/secrets/pw";
        # };

        user = mkOption {
          type = with types; str;
          default = "root";
          example = "jenkins";
          description = ''
            User that should own the secret file.
          '';
        };

        group = mkOption {
          type = with types; str;
          default = "root";
          example = "users";
          description = ''
            Group that should own the secret file.
          '';
        };
      };
    }
  ));

in
{
  options.veil = {
    mainIP = mkOption { type = with types; nullOr str; default = null; };
    machineName = mkOption { type = with types; nullOr str; default = config.networking.hostName; };
    mainUser = mkOption { type = with types; nullOr str; default = null; };
    secrets = mkOption {
      type = with types; attrsOf secretOptions;
      default = { };
    };
  };
}
