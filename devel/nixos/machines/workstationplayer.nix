{ config, lib, pkgs, inputs, nixrepo, ... }:
{
  imports = [
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
      use_builders = true;
    };
  };
  config.users.users.root.openssh.authorizedKeys.keys = config.users.users.jan.openssh.authorizedKeys.keys;
  #environment.systemPackages = with pkgs; [ ];

  # ToDo: This is a dirty hack so I can merge this with unfrees from other modles
  # no idea how to do it properly.
  config.unfrees = [ "discord" "typora" "hplip" "joypixels" "barracudavpn" "faac" ]; # ToDo: Move these to the modules that install them
  config.nixpkgs.config.allowUnfree = true;
  # config.nixpkgs.config.allowAliases = false;
  #nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.unfrees;

  config.virtualisation.vmware.guest.enable = true;
  # config.boot.kernelPackages = pkgs.linuxPackages_5_15;
  config.boot.initrd.availableKernelModules = [ "ata_piix" "mptspi" "uhci_hcd" "ehci_pci" "ahci" "xhci_pci" "sd_mod" "sr_mod" ];
  config.boot.initrd.kernelModules = [ ];
  config.boot.kernelModules = [ "kvm-amd" ];
  config.boot.extraModulePackages = [ ];
  config.networking.interfaces.ens33.useDHCP = true;
  config.networking.hostId = "1c47b078";
  #config.networking.hosts= { "192.168.0.10" = [ "confus.me" "conserve" "conserve.dynu.net" ]; };
  #console.font = "latarcyrheb-sun32";  # larger bootmode fonts
  #boot.loader.systemd-boot.consoleMode = lib.mkDefault "max";
  #hardware.video.hidpi.enable = true;
  config.roles.zfs.enable = true;
  config.boot.loader.systemd-boot.enable = true;
  config.boot.loader.efi.canTouchEfiVariables = true;
  config.networking.hostName = "conix";
  #networking.wireless.enable = true;
  config.networking.useDHCP = false;
  config.networking.networkmanager.enable = true;
  config.programs.nm-applet.enable = true;
  config.time.timeZone = "Europe/Vienna";
  config.hardware.opengl.driSupport32Bit = true;
  #hardware.opengl.extraPackages = [ pkgs.intel-ocl ];
  #hardware.bluetooth.enable = true;
  #services.blueman.enable = true;
  config.services.xserver.libinput.enable = true; # Enable touchpad and other input periphery support.
  config.services.xserver.videoDrivers = [ "wmware" ];
  config.services.perswitch.enable = true;
  config.services.printing.enable = true;
  # config.services.printing.drivers = [ pkgs.hplipWithPlugin ];  #pkgs.hplip
  config.programs.system-config-printer.enable = true;

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
      device = "/dev/disk/by-uuid/D806-C699";
      fsType = "vfat";
    };

  #swapDevices = [ "/dev/disk/by-uuid/a4566692-dc22-4fad-8c76-6260359da180" ];
  config.swapDevices = [
    {
      device = "/dev/disk/by-uuid/fa6b7340-3321-49fa-a602-d036c221e160";
      #device = "4c5e5e6c-01";
      #randomEncryption.enable = true;
    }
  ];

  config.system.stateVersion = "21.11";
}

# sudo cp -r ~/devel/nixos/ /etc/ && sudo chown -R root:root /etc/nixos/
