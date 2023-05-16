{ config, lib, pkgs, inputs, nixrepo, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    # sudo nix-channel --add https://github.com/NixOS/nixos-hardware/archive/master.tar.gz nixos-hardware"

    # ToDo: Falke this!
    ../modules
    ../users
  ] ++ (lib.optional (builtins.pathExists ../cachix.nix) ../cachix.nix);


  config.roles = {
    essentials = { enable = true; main_user = config.users.users.jan.name; };
    dev.enable = true;
    electronics.enable = true;
    windowed.enable = true;
    workstation.enable = true;
    cudawork = {
      enable = true;
      novpn = true;
      interception = false;
    };
  };
  config.users.users.root.openssh.authorizedKeys.keys = config.users.users.jan.openssh.authorizedKeys.keys;
  #environment.systemPackages = with pkgs; [ ];

  # ToDo: This is a dirty hack so I can merge this with unfrees from other modles
  # no idea how to do it properly.
  config.unfrees = [ "discord" "typora" "hplip" "joypixels" "barracudavpn" "faac" ]; # ToDo: Move these to the modules that install them
  #nixpkgs.config.allowUnfree = true;
  config.nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.unfrees;

  config.boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sdhci_pci" ];
  config.boot.initrd.kernelModules = [ ];
  config.boot.kernelModules = [ "kvm-intel" ];
  config.boot.extraModulePackages = [ ];
  #console.font = "latarcyrheb-sun32";  # larger bootmode fonts
  #boot.loader.systemd-boot.consoleMode = lib.mkDefault "max";
  #hardware.video.hidpi.enable = true;
  config.roles.zfs.enable = true;
  config.boot.loader.systemd-boot.enable = true;
  config.boot.loader.efi.canTouchEfiVariables = true;
  config.networking.hostName = "connote";
  #networking.wireless.enable = true;
  config.networking.useDHCP = false;
  config.networking.networkmanager.enable = true;
  config.programs.nm-applet.enable = true;
  config.time.timeZone = "Europe/Vienna";
  config.hardware.opengl.driSupport32Bit = true;
  #hardware.opengl.extraPackages = [ pkgs.intel-ocl ];
  #hardware.bluetooth.enable = true;
  #services.blueman.enable = true;
  config.services.xserver.libinput.enable = true; # Enable touchpad support.
  config.services.logind.lidSwitch = "ignore";
  config.networking.hostId = "5b07dc72";

  config.fileSystems."/" =
    {
      device = "rpool/root";
      fsType = "zfs";
    };

  config.fileSystems."/nix" =
    {
      device = "rpool/nix";
      fsType = "zfs";
    };

  config.fileSystems."/home" =
    {
      device = "rpool/home";
      fsType = "zfs";
    };

  config.fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/6EB0-B7B8";
      fsType = "vfat";
    };

  config.swapDevices = [ ];

  config.powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  config.system.stateVersion = "21.05";
}

# sudo cp -r ~/devel/nixos/ /etc/ && sudo chown -R root:root /etc/nixos/
