{ config, lib, pkgs, modulesPath, ... }:
#let
#pkgs = import (fetchTarball https://github.com/nixos/nixpkgs/archive/1b77b735ea.tar.gz) {};
#in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../modules
    ../users
  ] ++ (lib.optional (builtins.pathExists ./cachix.nix) ./cachix.nix);

  config.roles = {
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
 config.users.users.root.openssh.authorizedKeys.keys = config.users.users.jan.openssh.authorizedKeys.keys;
  #environment.systemPackages = with pkgs; [ ];
 # config.security.pki.certificates = [ (builtins.readFile ../cuda.crt) ];

  # ToDo: This is a dirty hack so I can merge this withconfig.unfrees. from other modles
  # no idea how to do it properly.
  #unfrees = [ "discord" "typora" "hplip" "joypixels" "barracudavpn" "faac" ];  # ToDo: Move these to the modules that install them
  #nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.unfrees;
 config.nixpkgs.config.allowUnfree = true;

 config.system.stateVersion = "21.05";

# sudo cp -r ~/devel/nixos/ /etc/ && sudo chown -R root:root /etc/nixos/
# nixos-install -I nixos=https://github.com/nixos/nixpkgs/archive/1b77b735ea.tar.gz
# {/mnt/etc/nixos/zfs-configuration.nix}
# nix-channel --add $(grep fetch configuration.nix | grep -o "https:.*gz") nixos
# grep channel /iso/nixos/yadmdotfiles-master/devel/nixos/utils/install_nixos.sh | grep -o "sudo .*hardware" 

  #boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sdhci_pci" ];
 config.boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
 config.boot.initrd.kernelModules = [ ];
 config.boot.kernelModules = [ "kvm-intel" ];
  #boot.blacklistedKernelModules = [ "psmouse" ];
 config.boot.extraModulePackages = [ ];
  #services.xserver.videoDrivers = lib.mkDefault [ "intel" ];
  #console.font = "latarcyrheb-sun32";  # larger bootmode fonts
  #boot.loader.systemd-boot.consoleMode = lib.mkDefault "max";
  #hardware.video.hidpi.enable = true;
 config.roles.zfs.enable = true;
 config.boot.loader.systemd-boot.enable = true;
 config.boot.loader.efi.canTouchEfiVariables = true;
 config.networking.hostName = "worklap";
  #networking.wireless.enable = true;
 config.networking.useDHCP = false;
 config.networking.networkmanager.enable = true;
 config.programs.nm-applet.enable = true;
 config.time.timeZone = "Europe/Vienna";
  #hardware.opengl.driSupport32Bit = true;
  #hardware.opengl.extraPackages = [ pkgs.intel-ocl ];
  #hardware.bluetooth.enable = true;
  #services.blueman.enable = true;
 config.services.xserver.libinput.enable = true;  # Enable touchpad support.
 config.services.logind.lidSwitch = "ignore";
 config.networking.hostId = "2684da09";

 config.fileSystems."/" =
    { device = "rpool/root";
      fsType = "zfs";
    };

 config.fileSystems."/nix" =
    { device = "rpool/nix";
      fsType = "zfs";
    };

 config.fileSystems."/home" =
    { device = "rpool/home";
      fsType = "zfs";
    };

 config.fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/889E-4233";
      fsType = "vfat";
    };

 config.swapDevices = [ ];

 config.powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}

