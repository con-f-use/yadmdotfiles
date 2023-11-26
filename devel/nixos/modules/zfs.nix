{ config, lib, pkgs, ... }:

{
  options.roles.zfs = {
    enable = lib.mkEnableOption "Some sensible zfs deaults";
  };
  config = lib.mkIf config.roles.zfs.enable {

    boot.initrd.supportedFilesystems = [ "zfs" ];
    boot.supportedFilesystems = [ "zfs" ];
    boot.zfs.enableUnstable = true;
    services.zfs.autoScrub.enable = true;
    boot.zfs.devNodes = "/dev/disk/by-partuuid"; # https://discourse.nixos.org/t/cannot-import-zfs-pool-at-boot/4805/14
    #services.zfs.trim.enable = true;
    #  services.fstrim = { enable = true; interval = "weekly"; };

    virtualisation.docker.storageDriver = "zfs";

    services.zfs.autoSnapshot = {
      enable = true;
      #frequent = 8; # keep the latest eight 15-minute snapshots (instead of four)
      #monthly = 1;  # keep only one monthly snapshot (instead of twelve)
    };

  };
}

