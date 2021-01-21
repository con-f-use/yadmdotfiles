{ config, lib, pkgs, modulesPath, ... }:
{

  virtualisation.vmware.guest.enable = true;
  boot.initrd.availableKernelModules = [ "ata_piix" "mptspi" "uhci_hcd" "ehci_pci" "ahci" "xhci_pci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  networking.interfaces.ens33.useDHCP = true;
  networking.hostId = "1c47b078";
  #console.font = "latarcyrheb-sun32";  # larger bootmode fonts
  #boot.loader.systemd-boot.consoleMode = lib.mkDefault "max";
  #hardware.video.hidpi.enable = true;
  roles.janZfs.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "conix";
  #networking.wireless.enable = true;
  networking.useDHCP = false;
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;
  time.timeZone = "Europe/Vienna";
  hardware.opengl.driSupport32Bit = true;
  #hardware.opengl.extraPackages = [ pkgs.intel-ocl ];
  #hardware.bluetooth.enable = true;
  #services.blueman.enable = true;
  services.xserver.libinput.enable = true;  # Enable touchpad and other input periphery support.
  services.perswitch.enable = true;
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplipWithPlugin ];  #pkgs.hplip
  programs.system-config-printer.enable = true;

  fileSystems."/" =
    { device = "rpool/root";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    { device = "rpool/nix";
      fsType = "zfs";
    };

  fileSystems."/home" =
    { device = "rpool/home";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/D806-C699";
      fsType = "vfat";
    };

  #swapDevices = [ "/dev/disk/by-uuid/a4566692-dc22-4fad-8c76-6260359da180" ];
  swapDevices = [
    {
      device = "/dev/disk/by-uuid/fa6b7340-3321-49fa-a602-d036c221e160";
      #device = "4c5e5e6c-01";
      #randomEncryption.enable = true;
    }
  ];

}
