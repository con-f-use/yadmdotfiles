{ config, lib, pkgs, inputs, ... }:
{
  roles = {
    essentials = { enable = true; main_user = config.users.users.jan.name; };
    dev.enable = true;
    electronics.enable = true;
    windowed.enable = true;
    workstation.enable = true;
    cudawork = {
      enable = true;
      use_builders = true;
    };
  };
  users.users.root.openssh.authorizedKeys.keys = config.users.users.jan.openssh.authorizedKeys.keys;
  #environment.systemPackages = with pkgs; [ ];

  # ToDo: This is a dirty hack so I can merge this with unfrees from other modles
  # no idea how to do it properly.
  allowUnfreePackages = [ "discord" "typora" "hplip" "joypixels" "barracudavpn" "faac" "vault.*" "nvidia.*" ];
  # config.nixpkgs.config.allowAliases = false;
  nixpkgs.hostPlatform = "x86_64-linux";
  #nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.unfrees;

  virtualisation.vmware.guest.enable = true;
  virtualisation.docker.storageDriver = "zfs";
  # config.boot.kernelPackages = pkgs.linuxPackages_5_15;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  boot.initrd.availableKernelModules = [  "nvme" "usbhid" "ata_piix" "mptspi" "uhci_hcd" "ehci_pci" "ahci" "xhci_pci" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  # networking.interfaces.ens33.useDHCP = true;
  networking.hostId = "1c47b078";
  #config.networking.hosts= { "192.168.0.10" = [ "confus.me" "conserve" "conserve.dynu.net" ]; };
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
  services.xserver.libinput.enable = true; # Enable touchpad and other input periphery support.
  services.xserver.videoDrivers = [ "nvidia" "vmware" ];
  hardware.opengl = {
    enable = true;
    driSupport = true;
  };
  hardware.nvidia = {
    modesetting.enable = true;
    hardware.nvidia.forceFullCompositionPipeline = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  services.perswitch.enable = true;
  services.printing.enable = true;
  # config.services.printing.drivers = [ pkgs.hplipWithPlugin ];  #pkgs.hplip
  programs.system-config-printer.enable = true;

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
      device = "/dev/disk/by-uuid/D806-C699";
      fsType = "vfat";
    };

  #swapDevices = [ "/dev/disk/by-uuid/a4566692-dc22-4fad-8c76-6260359da180" ];
  swapDevices = [
    #{
    #  device = "/dev/disk/by-uuid/fa6b7340-3321-49fa-a602-d036c221e160";
    #  options = [ "nofail" ];
    #  #device = "4c5e5e6c-01";
    #  #randomEncryption.enable = true;
    #}
  ];

  system.stateVersion = "21.11";
}

# sudo cp -r ~/devel/nixos/ /etc/ && sudo chown -R root:root /etc/nixos/
