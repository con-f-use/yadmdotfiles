{ ... }:
let
  transmissionSecretLocation = "/etc/secrets/transmission/transmission_secrets.json";
  transmissionDownloadPath = "/mnt/Media/Downloads";
  transmissionIncompletePath = "${transmissionDownloadPath}/.incomplete";
  transmissionWatchPath = "${transmissionDownloadPath}/.watch";
  transmissionRpcPort = 9091;
  transmissionExternalPort = 60191;
in
{
  # WebUI and Streaming
  services.jellyfin = {
    enable = true;
    openFirewall = builtins.trace "block jellyfin port in  (behind nginx)" true;
    group = "conserve";
  };

  # Shows
  services.sonarr = {
    enable = true;
    openFirewall = builtins.trace "block sonarr port in  (behind nginx)" true;
    group = "conserve";
    # user = "deluge";
    #dataDir = ;
  };

  # Movies
  services.radarr = {
    enable = true;
    openFirewall = builtins.trace "block radarr port in  (behind nginx)" true;
    group = "conserve";
    # user = "deluge";
    # dataDir = ;
  };

  # Audio Books
  services.lidarr = {
    enable = true;
    openFirewall = builtins.trace "block lidarr port in (behind nginx)" true;
    group = "conserve";
    # user = "";
    # dataDir = "";
  };

  # Sources
  services.jackett = {
    enable = true;
    openFirewall = builtins.trace "block jackett port in (behind nginx)" true;
    # group = ;
    # user = ;
    # dataDir = ;
  };

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
      rpc-whitelist = "192.168.*.*";
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

  systemd.tmpfiles.rules = [
    "z ${transmissionSecretLocation} 440 root conserve"
    "A+ /etc/secrets - - - - group:conserve:X"
    "d!- ${transmissionDownloadPath} 770 jan conserve"
    "A+ ${transmissionDownloadPath} - - - - group:conserve:rwX"
    "d!- ${transmissionIncompletePath} 770 jan conserve"
    "A+ ${transmissionIncompletePath} - - - - group:conserve:rwX"
    "d!- ${transmissionWatchPath} 770 jan conserve"
    "A+ ${transmissionWatchPath} - - - - group:conserve:rwX"
  ];
}
