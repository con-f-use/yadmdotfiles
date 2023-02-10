{ config, lib, pkgs, ... }:
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

  config.environment.etc."sshd/principals/principal".text = lib.concatStrings (
    lib.mapAttrsToList (
      name: config:
      ''
        # ${name}
        ${lib.generators.toPretty {} config.openssh.authorizedPrincipals}
      ''
    )
    config.users.users
  );
}

