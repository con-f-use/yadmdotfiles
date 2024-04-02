{ config, lib, pkgs, ... }:

{
  imports = [ ./system.nix ../conserve6/bash.nix ];  # ToDo: make bash a module

  roles = {
    essentials = {
      enable = true;
      main_user = config.users.users.jan.name;
    };
    workstation.enable = true;
    cudawork = {
      enable = true;
      novpn = false;
      interception = true;
      use_builders = true;
    };
    dev.enable = true;
    zfs.enable = true;
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  networking.hostName = "janix";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Vienna";

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.xkb.layout = "us";
  services.xserver.xkb.variant = "intl";
  services.xserver.xkb.options = "caps:escape";
  services.kubo.enable = lib.mkForce false;

  # services.printing.enable = true;

  services.xserver.libinput.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    curl
    firefox
    signal-desktop
    tessen
    wget
    wofi
    flameshot
  ];

  nixpkgs.config.joypixels.acceptLicense = true;
  allowUnfreePackages = [ "joypixels.*" ];
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.stateVersion = "23.05"; # Don't ever change this!
}
