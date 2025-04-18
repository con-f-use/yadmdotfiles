{ config
, lib
, pkgs
, ...
}:
let
  ddclientSecretLocation = "/etc/secrets/ddclient/ddclient.conf";
  transmissionSecretLocation = "/etc/secrets/transmission/transmission_secrets.json";
  transmissionDownloadPath = "/mnt/Media/Downloads";
  transmissionIncompletePath = "${transmissionDownloadPath}/.incomplete";
  transmissionWatchPath = "${transmissionDownloadPath}/.watch";
  transmissionRpcPort = 9091;
  transmissionExternalPort = 60191;
  sonarrShowsPath = "/mnt/Media/Shows";
  mail = "con-f-use@gmx.net";
  primary = "confus.me";
  secondary = "conserve.dynu.net";
  webhome = "/var/www/html";
in
{
  services.jellyfin = {
    enable = true;
    group = "conserve";
  }; # WebUI for Streaming
  services.sonarr = {
    enable = true;
    group = "conserve";
  }; # Shows
  services.radarr = {
    enable = true;
    group = "conserve";
  }; # Movies
  services.lidarr = {
    enable = true;
    group = "conserve";
  }; # Audio
  services.prowlarr.enable = true; # Sources
  # services.jackett = {
  #   enable = true;
  #   openFirewall = builtins.trace "block jackett port in firewall (behind nginx)" true;
  #   # group = ;
  #   # user = ;
  #   # dataDir = ;
  # };

  services.transmission = {
    # see: https://search.nixos.org/options?channel=unstable&show=services.transmission.settings&from=0&size=50
    enable = true;
    group = "conserve";

    openFirewall = builtins.trace "block transmission port in prod (behind nginx)" true;
    openRPCPort = builtins.trace "block transmission rpc port in prod (behind nginx)" true;
    credentialsFile = transmissionSecretLocation;

    settings = {
      download-dir = transmissionDownloadPath;
      incomplete-dir = transmissionIncompletePath;

      peer-port = transmissionExternalPort;

      rpc-enabled = true;
      rpc-port = transmissionRpcPort;
      rpc-username = "transmissionrpc";
      rpc-authentication-required = true;

      # script-torrent-done-enabled = true;
      # script-torrent-done-filename = "/some/path";

      rpc-bind-address = "0.0.0.0";
      rpc-whitelist-enabled = true;

      # see: https://github.com/transmission/transmission/blob/main/docs/Editing-Configuration-Files.md
      rpc-whitelist = "192.168.*.* 127.0.*.*";
      anti-brute-force-enabled = true;
      watch-dir-enabled = true;
      watch-dir = transmissionWatchPath;
      encryption = 2; # require encryption
      download-queue-size = 10;
      ratio-limit-enabled = true;
      speed-limit-up-enabled = true;
      speed-limit-up = 18; # KB/s
      alt-speed-enabled = true;
      alt-speed-time-enabled = true;
      alt-speed-time-begin = 480; # minutes from midnight, 480 = 08:00 am
      alt-speed-time-end = 1080; # 1180 = 18:00 pm
      alt-speet-up = 15; # KB/s
      alt-speed-down = 1500; # KB/s
    };
  };
  systemd.services.transmission.serviceConfig = {
    Restart = "always";
    RestartSec = 5;
    MemoryMax = "4G"; # Transmission 3.0 leaks memory
  };
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "transmission-add" ''
      set -o errexit -o pipefail -o nounset

      target=''${1:?Need target as first argument}
      shift
      TR_AUTH="transmissionrpc:$(${lib.getExe pkgs.jq} -r '."rpc-password"' '${transmissionSecretLocation}')" \
          transmission-remote 127.0.0.1 --authenv --add "$target"
    '')
  ];

  veil.secrets.transmission = {
    target = transmissionSecretLocation;
    script = "gopass show Infrastructure/conserve6_transmission";
    group = "conserve";
  };

  systemd.tmpfiles.rules = [
    "z ${transmissionSecretLocation} 0440 root conserve"
    "A+ /etc/secrets - - - - group:conserve:X"
    "d!- ${transmissionDownloadPath} 0770 jan conserve"
    "A+ ${transmissionDownloadPath} - - - - group:conserve:rwX"
    "d!- ${transmissionIncompletePath} 0770 jan conserve"
    "A+ ${transmissionIncompletePath} - - - - group:conserve:rwX"
    "d!- ${transmissionWatchPath} 0770 jan conserve"
    "A+ ${transmissionWatchPath} - - - - group:conserve:rwX"
    "d!- ${sonarrShowsPath} 0770 jan conserve"
    "A+ ${sonarrShowsPath} - - - - group:conserve:rwX"

    # ToDo: factor out together with html root
    "d!- ${webhome} 0750 jan ${config.services.nginx.user}"
    "C- ${webhome}/index.html - - - - ${./index.html}"
    "z- ${webhome}/index.html 0640 jan ${config.services.nginx.user}"
  ];

  services.nginx =
    let
      virtualHosts = {

        "${primary}" = {
          forceSSL = true;
          # addSSL = true;
          enableACME = true;
          # serverAliases = [ "${config.veil.mainIP}" ];
          default = true;

          locations = {
            # We have the Servarr-suite as locations instead of subdomains
            # so we can access them by IP, too and don't need to make an extra
            # ACME request for each of them

            "^~ /jelly" = {
              proxyPass = "http://127.0.0.1:8096";
              proxyWebsockets = true;
              extraConfig = ''
                proxy_hide_header X-Frame-Options;
                proxy_buffering off;
              '';
            };

            "^~ /sonarr".proxyPass = "http://127.0.0.1:8989";
            "^~ /sonarr/api" = {
              proxyPass = "http://127.0.0.1:8989";
              extraConfig = "auth_basic off;";
            };

            "^~ /radarr".proxyPass = "http://127.0.0.1:7878";
            "^~ /radarr/api" = {
              proxyPass = "http://127.0.0.1:7878";
              extraConfig = "auth_basic off;";
            };

            "^~ /lidarr".proxyPass = "http://127.0.0.1:8686";
            "^~ /lidarr/api" = {
              proxyPass = "http://127.0.0.1:8686";
              extraConfig = "auth_basic off;";
            };

            "^~ /prowlarr".proxyPass = "http://127.0.0.1:9696";
            "^~ /prowlarr/api" = {
              proxyPass = "http://127.0.0.1:9696";
              extraConfig = "auth_basic off;";
            };

            "^~ /transmission" = {
              proxyPass = "http://127.0.0.1:9091";
              proxyWebsockets = true;
              # extraConfig = ''
              #   proxy_hide_header X-Frame-Options;
              #   proxy_buffering off;
              # '';
            };

            "^~ /mothershipper".proxyPass = "http://127.0.0.1:9280";
            # ToDo: factor out html root
            "/".root = webhome;
          };
        }; # // crtcfg;

      }; # end: virtualHosts;
    in
    {
      enable = true;
      appendHttpConfig = ''
        error_log stderr;
        access_log syslog:server=unix:/dev/log combined;
        proxy_headers_hash_max_size 2048;
        proxy_headers_hash_bucket_size 128;
      '';
      recommendedGzipSettings = true;
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedTlsSettings = true;

      virtualHosts = virtualHosts // {
        # "${secondary}" = virtualHosts."${primary}"; # ToDo: move when refactoring html root
        #   "transmission.${secondary}" = virtualHosts."transmission.${primary}";
        #   "jelly.${secondar}" = virtualHosts."jelly.${primary}";
      };
    };
  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  # https://thedutch.dev/setup-dynamic-dns-with-ddclient-and-porkbun
  services.ddclient = {
    enable = true;
    # protocol = "porkbun";
    # interval = "9000";  # seconds
    # domains = [ "confus.me" ];
    # passwordFile = "/etc/secrets/ddclient/ddclient.conf";  # really a conf file with `apikey=...` and `secretapikey=...`
    configFile = ddclientSecretLocation;
  };

  veil.secrets.ddclient = {
    target = ddclientSecretLocation;
    script = "gopass show Infrastructure/conserve6_ddclient";
  };

  security.acme.acceptTerms = true;
  security.acme.defaults.dnsProvider = "porkbun";
  security.acme.defaults.email = mail;
  security.acme.defaults.credentialFiles = {
    PORKBUN_API_KEY_FILE = "/etc/secrets/letsencrypt/api_key";
    PORKBUN_SECRET_API_KEY_FILE = "/etc/secrets/letsencrypt/secret_api_key";
  };
  security.acme.certs = {
  #   "${secondary}".email = mail;
  #   "trasmission.${secondary}".email = mail;
  #   "jelly.${secondary}".email = mail;
  #   "sonarr.${secondary}".email = mail;
  #   "radarr.${secondary}".email = mail;
  #   "lidarr.${secondary}".email = mail;
  #   "prowlarr.${secondary}".email = mail;
    "${primary}".email = mail;
    "transmission.${primary}".email = mail;
    "jelly.${primary}".email = mail;
    "sonarr.${primary}".email = mail;
    "radarr.${primary}".email = mail;
    "lidarr.${primary}".email = mail;
    "prowlarr.${primary}" .email = mail;
  };
}
