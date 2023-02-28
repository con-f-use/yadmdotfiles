{ config, lib, ... }:
{
  options.users.users = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, config, ... }: {
          options.openssh.authorizedPrincipals = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
          };
          config.extraGroups = config.openssh.authorizedPrincipals;
        }
      )
    );
  };

  config = lib.mkIf config.services.openssh.enabled {
    environment.etc = lib.mapAttrs' (
      _: { openssh, name, ... }: {
        name = "sshd/principals/${name}";
        value.text = ''${lib.strings.concatMapStrings (x: x + "\n") openssh.authorizedPrincipals}'';
      }) (lib.filterAttrs (_: u: u.openssh.authorizedPrincipals != []) config.users.users)
    ;

    services.openssh = lib.mkIf config.services.openssh.enabled {
      extraConfig = ''
        AuthorizedPrincipalsFile /etc/sshd/principals/%u
        TrustedUserCAKeys /etc/ssh/trusted-user-authorities.crt
      '';
    };
  };
}

# Configure user authority like so:
# config.environment.etc."ssh/trusted-user-authorities.crt".source = pkgs.fetchurl {
#   url = "...";
#   hash = "";  # Mandatory! Verify!
#   curlOpts = "--insecure";  # fine because hash is checked
# };
