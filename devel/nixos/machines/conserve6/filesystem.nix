{ ... }:

# ToDo: Movies
# ToDo: Backup
# ToDo: Data
# ...maybe with systemd.automounts?
# see:
# - https://github.com/make-github-pseudonymous-again/blog/blob/master/content/post/2018-05-24-automatically-mount-luks-encrypted-device-with-systemd.md
# - https://search.nixos.org/options?channel=unstable&show=systemd.automounts
# - https://github.com/viperML/neoinfra/blob/50c0875fbf95c94ade5956ba0979525041eb3fef/modules/oci-lustrate-oracle9/default.nix#L20
let
  id2d = uuid: "/dev/disk/by-uuid/${uuid}";
in
{
  # boot.zfs.forceImportRoot = false;
  boot.supportedFilesystems = [
    "ntfs"
    "btrfs" # "zfs"  # zfs pending vet for latest nixos kernel
  ];

  boot.initrd.luks = {
    reusePassphrases = true;
    devices."conserve6".device = id2d "a8afd5ea-d5d9-4c21-aed8-44da7efdfd4a"; # root luks
    devices."extshows".device = id2d "06127ecb-de8f-45b0-9da2-52f23b68b1d4"; # shows luks
    devices."extmovs".device = id2d "875c71bb-00b0-4377-ad73-8bb079eb6592"; # movies luks
    forceLuksSupportInInitrd = true;
  };

  fileSystems = {
    "/boot" = {
      device = id2d "67B4-DC3C";
      fsType = "vfat";
    };
    "/" = {
      device = id2d "dedcd975-a6f5-4583-8420-1c39d6a6183a";  # root inner
      fsType = "ext4";
    };
    "/mnt/Media/Shows" = {
      device = id2d "e2dc30f5-0bec-464c-a29f-49814f5e9fe3";  # shows inner
      fsType = "ext4";
    };
    "/mnt/Media/Movies" = {
      device = id2d "db1bb22b-f02b-43b3-842b-9006cee84b0f";  # movies inner
      fsType = "ext4";
    };
  };

  swapDevices = [{ device = "/swapfile"; size = 33000; }];
}
