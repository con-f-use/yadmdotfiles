{ config, ... }:
let
  secretDir = "/etc/secrets/${config.services.forgejo.user}";
  port = 7030;
in
{
  services.forgejo = {
    enable = true;
    lfs.enable = true;
    # database.passwordFile = "${secretDir}/database/pw";
    # mailerPasswordFile = "${secretDir}/mailerpw";
    settings = {
      # see: https://forgejo.org/docs/latest/admin/config-cheat-sheet/
      server.HTTP_PORT = port;
      service.REGISTER_MANUAL_CONFIRM = true;
      service.DISABLE_REGISTRATION = true;
    };
  };

  networking.firewall.allowedTCPPorts = [
    #(builtins.trace "block forgejo port ${port} in prod" port)
    config.services.forgejo.settings.server.SSH_PORT
  ];

  systemd.tmpfiles.rules = [
    "d!- ${secretDir}/database 0750 forgejo root"
    "Z ${secretDir} 0750 forgejo root"
    "A+ /etc/secrets - - - - user:${config.services.forgejo.user}:rX"
  ];
}
