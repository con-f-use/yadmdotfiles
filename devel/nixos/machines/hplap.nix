{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    # sudo nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware"
    <nixos-hardware/common/cpu/intel>
    <nixos-hardware/common/pc/laptop>
    <nixos-hardware/common/pc/ssd>
  ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  #console.font = "latarcyrheb-sun32";  # larger bootmode fonts
  #boot.loader.systemd-boot.consoleMode = lib.mkDefault "max";
  #hardware.video.hidpi.enable = true;
  roles.zfs.enable = true;
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
  services.xserver.libinput.enable = true;  # Enable touchpad support.
  services.logind.lidSwitch = "ignore";
  networking.hostId = "5b07dc72";

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
    { device = "/dev/disk/by-uuid/6EB0-B7B8";
      fsType = "vfat";
    };

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}

