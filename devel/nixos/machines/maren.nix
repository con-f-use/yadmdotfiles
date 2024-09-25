{
  self,
  config,
  lib,
  ...
}:
{
  roles = {
    essentials = {
      enable = true;
      main_user = config.users.users.jan.name;
    };
    dev.enable = true;
    windowed.enable = true;
    workstation.enable = true;
    cudawork = {
      enable = true;
      interception = true;
    };
    cudawork.novpn = false;
    cudawork.use_builders = true;
  };
  services.kubo.enable = lib.mkForce false;
  users.users.root.openssh.authorizedKeys.keys = config.users.users.jan.openssh.authorizedKeys.keys;
  #environment.systemPackages = with pkgs; [ ];
  # config.security.pki.certificates = [ (builtins.readFile ../cuda.crt) ];

  # ToDo: This is a dirty hack so I can merge this withconfig.unfrees. from other modles
  # no idea how to do it properly.
  #unfrees = [ "discord" "typora" "hplip" "joypixels" "barracudavpn" "faac" ];  # ToDo: Move these to the modules that install them
  #nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.unfrees;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "x86_64-linux";

  system.stateVersion = "21.05";

  # sudo cp -r ~/devel/nixos/ /etc/ && sudo chown -R root:root /etc/nixos/
  # nixos-install -I nixos=https://github.com/nixos/nixpkgs/archive/1b77b735ea.tar.gz
  # {/mnt/etc/nixos/zfs-configuration.nix}
  # nix-channel --add $(grep fetch configuration.nix | grep -o "https:.*gz") nixos
  # grep channel /iso/nixos/yadmdotfiles-master/devel/nixos/utils/install_nixos.sh | grep -o "sudo .*hardware" 

  #boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [
    "kvm-intel"
    "r8152"
  ];
  #boot.blacklistedKernelModules = [ "psmouse" ];
  boot.extraModulePackages = [ ];
  #services.xserver.videoDrivers = lib.mkDefault [ "intel" ];
  #console.font = "latarcyrheb-sun32";  # larger bootmode fonts
  #boot.loader.systemd-boot.consoleMode = lib.mkDefault "max";
  #hardware.video.hidpi.enable = true;
  roles.zfs.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  networking.hostName = "worklap";
  #networking.wireless.enable = true;
  networking.useDHCP = false;
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;
  time.timeZone = "Europe/Vienna";
  #hardware.opengl.driSupport32Bit = true;
  #hardware.opengl.extraPackages = [ pkgs.intel-ocl ];
  #hardware.bluetooth.enable = true;
  #services.blueman.enable = true;
  services.xserver.libinput.enable = true; # Enable touchpad support.
  services.logind.lidSwitch = "ignore";
  networking.hostId = "2684da09";

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
    device = "/dev/disk/by-uuid/889E-4233";
    fsType = "vfat";
  };

  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
