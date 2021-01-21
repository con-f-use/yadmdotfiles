
{ config, lib, pkgs, ... }:

{ options.roles.janZfs = {
  enable = lib.mkEnableOption "Some sensible zfs deaults";
};
config = lib.mkIf config.roles.janZfs.enable {

   boot.initrd.supportedFilesystems = [ "zfs" ];
   boot.supportedFilesystems = [ "zfs" ];
   boot.zfs.enableUnstable = true;
   services.zfs.autoScrub.enable = true;
   boot.zfs.devNodes = "/dev/disk/by-partuuid";  # https://discourse.nixos.org/t/cannot-import-zfs-pool-at-boot/4805/14
   #services.zfs.trim.enable = true;

   services.zfs.autoSnapshot = {
     enable = true;
     #frequent = 8; # keep the latest eight 15-minute snapshots (instead of four)
     #monthly = 1;  # keep only one monthly snapshot (instead of twelve)
   };

 }; }

