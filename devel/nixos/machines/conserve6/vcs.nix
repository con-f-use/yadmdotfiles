{ config, ... }:
let
  secretDir = "/etc/secrets/${config.services.forgejo.user}";
  port = 7030;
  secondary = "conserve.dynu.net";
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
      server.ROOT_URL = "%(PROTOCOL)s://%(DOMAIN)s:%(HTTP_PORT)s/forgejo";  # ToDo: try with trailing slash here, but without below
      server.SSH_PORT = 7022;
      server.START_SSH_SERVER = true;
      # server.LOCAL_ROOT_URL = "%(PROTOCOL)s://%(DOMAIN)s:%(HTTP_PORT)s/forgejo";
      # server.STATIC_URL_PREFIX = "/forgejo/public";
      # server.HTTP_ADDR = "listen address";
      service.REGISTER_MANUAL_CONFIRM = true;
      service.DISABLE_REGISTRATION = true;
    };
  };

  networking.firewall.allowedTCPPorts = [
    (builtins.trace "block forgejo port ${builtins.toString port} in prod" port)
    config.services.forgejo.settings.server.SSH_PORT
  ];

  services.nginx.virtualHosts.${secondary}.locations = {
    # see: https://docs.gitea.com/administration/reverse-proxies#nginx-with-a-sub-path
    "^~ /forgejo/" = {
      proxyPass = "http://127.0.0.1:${builtins.toString port}/";  # trailing slash seems to be important
    };
    "^~ /forgejo" = {
      proxyPass = "http://127.0.0.1:${builtins.toString port}/";  # trailing slash seems to be important
    };
  };

  systemd.tmpfiles.rules = [
    "d!- ${secretDir}/database 0750 forgejo root"
    "Z ${secretDir} 0750 forgejo root"
    "A+ /etc/secrets - - - - user:${config.services.forgejo.user}:rX"
  ];
}
