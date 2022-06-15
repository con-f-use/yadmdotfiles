{ config, lib, pkgs, modulesPath, ... }:
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

  config.nixpkgs.config.allowUnfree = true;
  config.system.stateVersion = "21.11";
 
  config.boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod" ];
  config.boot.kernelPackages = pkgs.linuxPackages_5_15;
  config.boot.initrd.kernelModules = [ ];
  config.boot.kernelModules = [ "kvm-intel" ];

  config.boot.extraModulePackages = [ ];
  #console.font = "latarcyrheb-sun32";  # larger bootmode fonts
  #boot.loader.systemd-boot.consoleMode = lib.mkDefault "max";
  #hardware.video.hidpi.enable = true;
  config.boot.loader.systemd-boot.enable = true;
  config.boot.loader.efi.canTouchEfiVariables = true;
  config.networking.hostName = "contort";
  config.networking.useDHCP = false;
  # config.networking.interfaces.enp0s13f0u4.useDHCP = true;  # zielstatt usb network adapter
  config.networking.networkmanager.enable = true;
  config.programs.nm-applet.enable = true;
  config.time.timeZone = "Europe/Vienna";
  #hardware.opengl.driSupport32Bit = true;
  #hardware.opengl.extraPackages = [ pkgs.intel-ocl ];
  #hardware.bluetooth.enable = true;
  #services.blueman.enable = true;
  config.services.xserver.libinput.enable = true;  # Enable touchpad support.
  config.services.logind.lidSwitch = "ignore";
  config.networking.hostId = "f3dc4d2a";

  config.roles.zfs.enable = true;
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
     { device = "/dev/disk/by-uuid/8E11-3B68";
       fsType = "vfat";
     };
  config.swapDevices = [ ];

  config.powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  config.hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

