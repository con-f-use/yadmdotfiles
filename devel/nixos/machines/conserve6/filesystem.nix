{ ... }:

let
  id2d = uuid: "/dev/disk/by-uuid/${uuid}";
in
{
  # boot.zfs.forceImportRoot = false;
  boot.supportedFilesystems = [
    "ntfs" "btrfs" # "zfs"  # zfs pending vet for latest nixos kernel
  ];

  boot.initrd.luks = {
    reusePassphrases = true;
    devices."conserve6".device = id2d "a8afd5ea-d5d9-4c21-aed8-44da7efdfd4a";
    forceLuksSupportInInitrd = true;
  };

  fileSystems = {
    "/" = {
      device = id2d "dedcd975-a6f5-4583-8420-1c39d6a6183a";
      fsType = "ext4";
    };
    "/boot" = {
      device = id2d "67B4-DC3C";
      fsType = "vfat";
    };
  };

  swapDevices = [{ device = "/swapfile"; size = 33000; }];
}
