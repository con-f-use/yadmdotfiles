{ config
, lib
, pkgs
, inputs
, nixrepo
, modulesPath
, ...
}:
{
  roles = {
    essentials = {
      enable = true;
      main_user = config.users.users.jan.name;
    };
    bashbling.enable = true;
    dev.enable = true;
    windowed.enable = true;
    workstation.enable = true;
    cudawork = {
      enable = true;
      interception = true;
    };
    cudawork.novpn = false;
    cudawork.use_builders = true;
    networks = {
      enable = true;
      ethernet = "";
      wifi = "wlp166s0";
    };
  };
  users.users.root.openssh.authorizedKeys.keys = config.users.users.jan.openssh.authorizedKeys.keys;
  users.mutableUsers = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "x86_64-linux";
  system.stateVersion = "22.05";
  virtualisation.docker.storageDriver = "zfs";

  services.zerotierone = {
    enable = true;
    joinNetworks = [
      "A0CBF4B62ABCE52E"
    ];
    # localConfig = { allowDNS = true; };
  };
  services.zeronsd.servedNetworks."A0CBF4B62ABCE52E".settings = {
    domain = "zero.tier";
    token = "/var/lib/zerotier-one/token";
  };

  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "sd_mod"
    "xe"
  ];
  # boot.kernelPackages = pkgs.linuxPackages_latest;
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
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.printing.enable = true;
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };
  services.libinput.enable = true; # Enable touchpad support.
  services.logind.lidSwitch = "ignore";
  networking.hostId = "f3dc4d2a";
  my.roles.gaming-client.enable = true;
  services.pulseaudio.enable = false; # replaced by pipewire
  services.pipewire = {
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    # systemWide = true;
  };

  roles.zfs.enable = true;
  fileSystems."/" = {
    device = "rpool/root";
    fsType = "zfs";
  };

  fileSystems."/nix" = {
    device = "rpool/nix";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "rpool/home";
    fsType = "zfs";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/C1DA-4C5B";
    fsType = "vfat";
  };
  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.enableAllFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
}
