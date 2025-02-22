{ self
, config
, lib
, pkgs
, inputs
, ...
}:
let
  mocondat = pkgs.writeScriptBin "mocondat" ''
    gopass show -o Infrastructure/janpw | sudo -S true
    sleep .5
    sudo cryptsetup luksOpen /dev/disk/by-uuid/bcca372b-f99a-41f1-8a86-c9431a3cee78 crydat1 --key-file=/home/jan/.cry-con/cry-con-dat
    sudo mount -o defaults,users /dev/mapper/crydat1 /media/condat1/
  '';
in
{
  #system.nixos.tags = [ "conix-305" ];
  roles = {
    essentials = {
      enable = true;
      main_user = config.users.users.jan.name;
    };
    dev.enable = true;
    bashbling.enable = true;
    virt.enable = true;
    electronics.enable = true;
    windowed.enable = true;
    workstation.enable = true;
    networks = {
      enable = true;
      wifi = "wlp166s0";
      ethernet = "enp5s0";
    };
    cudawork = {
      enable = true;
      use_builders = true;
    };
  };
  services.envfs.enable = lib.mkForce true;  # ToDo: remove this
  users.users.root.openssh.authorizedKeys.keys = config.users.users.jan.openssh.authorizedKeys.keys;
  environment.systemPackages = with pkgs; [
    gst_all_1.gstreamer
    mocondat
    pamixer
    alejandra
    # self.inputs.mcomnix.legacyPackages.${pkgs.system}.mcomix
    mcomix
    transmission_4-gtk
  ];

  veil.machineName = "conix";

  # ToDo: This is a dirty hack so I can merge this with unfrees from other modles
  # no idea how to do it properly.
  allowUnfreePackages = [
    "discord"
    "typora"
    "hplip"
    "joypixels"
    "barracudavpn"
    "faac"
    "vault.*"
    "nvidia.*"
    "libXNVCtrl*"
  ];
  # permittedInsecurePackages = [ "python3.12-youtube-dl-2021.12.17" ];
  # config.nixpkgs.config.allowAliases = false;
  nixpkgs.hostPlatform = "x86_64-linux";
  #nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.unfrees;

  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
    "riscv64-linux"
    "wasm64-wasi"
  ];
  virtualisation.vmware.guest.enable = true;
  virtualisation.docker.storageDriver = "zfs";
  # config.boot.kernelPackages = pkgs.linuxPackages_5_15;
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  boot.initrd.availableKernelModules = [
    "nvme"
    "usbhid"
    "ata_piix"
    "mptspi"
    "uhci_hcd"
    "ehci_pci"
    "ahci"
    "xhci_pci"
    "sd_mod"
    "sr_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  # networking.interfaces.ens33.useDHCP = true;
  networking.hostId = "1c47b078";
  # networking.hosts = { "192.168.1.10" = [ "confus.me" "conserve" "conserve.dynu.net" ]; };
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
  #hardware.opengl.extraPackages = [ pkgs.intel-ocl ];
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.libinput.enable = true; # Enable touchpad and other input periphery support.
  services.xserver.videoDrivers = [
    "nvidia"
    "vmware"
  ];
  # services.xserver.videoDrivers = [ "nvidia" ];
  hardware.graphics.enable = true;
  hardware.nvidia = {
    modesetting.enable = true;
    forceFullCompositionPipeline = true;
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
    # package = config.boot.kernelPackages.nvidiaPackages.stable;
    # package = pkgs.linuxKernel.packages.linux_6_6.nvidia_x11_beta;
    # package = pkgs.linuxKernel.packages.linux_6_6.nvidia_x11_legacy535;
    package = config.boot.kernelPackages.nvidiaPackages.legacy_535;
  };

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

  # services.flatpak.enable = true;
  # xdg.portal = {
  #   enable = true;
  #   extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
  #   config.common.default = "gtk";
  # };
  services.perswitch.enable = true;
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.hplipWithPlugin ]; #pkgs.hplip
  programs.system-config-printer.enable = true;

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

  security.sudo.extraRules = [
    {
      users = [ "jan" ];
      commands = [{ command = "${mocondat}/bin/mocondat"; options = [ "NOPASSWD" ]; }];
    }
  ];

  system.stateVersion = "21.11";
}

# sudo cp -r ~/devel/nixos/ /etc/ && sudo chown -R root:root /etc/nixos/
