{ config, lib, pkgs, inputs, nixrepo, modulesPath, ... }:
{
  roles = {
    essentials = { enable = true; main_user = config.users.users.jan.name; };
    dev.enable = true;
    windowed.enable = true;
    workstation.enable = true;
    cudawork = {
      enable = true;
      interception = true;
    };
    cudawork.novpn = false;
    cudawork.use_builders = false;
  };
  users.users.root.openssh.authorizedKeys.keys = config.users.users.jan.openssh.authorizedKeys.keys;
  users.mutableUsers = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "22.05";
  virtualisation.docker.storageDriver = "zfs";

  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];

  boot.extraModulePackages = [ ];
  #console.font = "latarcyrheb-sun32";  # larger bootmode fonts
  #boot.loader.systemd-boot.consoleMode = lib.mkDefault "max";
  #hardware.video.hidpi.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "contort";
  # networking.wireless.enable = true;
  networking.useDHCP = false;
  # config.networking.interfaces.enp0s13f0u4.useDHCP = true;  # zielstatt usb network adapter
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;
  time.timeZone = "Europe/Vienna";
  #hardware.opengl.driSupport32Bit = true;
  #hardware.opengl.extraPackages = [ pkgs.intel-ocl ];
  #hardware.bluetooth.enable = true;
  #services.blueman.enable = true;
  services.xserver.libinput.enable = true; # Enable touchpad support.
  services.logind.lidSwitch = "ignore";
  networking.hostId = "f3dc4d2a";

  roles.zfs.enable = true;
  fileSystems."/" =
    {
      device = "rpool/root";
      fsType = "zfs";
    };

  fileSystems."/nix" =
    {
      device = "rpool/nix";
      fsType = "zfs";
    };

  fileSystems."/home" =
    {
      device = "rpool/home";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/C1DA-4C5B";
      fsType = "vfat";
    };
  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.enableAllFirmware = true;
  # hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.cpu.intel.updateMicrocode = true;
}

#lrwxrwxrwx 1 root root 15 Aug 21 23:38  -> ../../nvme0n1p1
