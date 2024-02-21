{ config, lib, pkgs, ... }:

{
  imports = [ ./system.nix ];

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
  services.xserver.layout = "us";
  services.xserver.xkbVariant = "intl";
  services.xserver.xkbOptions = "caps:escape";

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

  programs.starship = {
    enable = true;
    settings = lib.importTOML ./nerd-font-symbols.toml;
  };

  fonts.packages = with pkgs; [
      cantarell-fonts
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji
      liberation_ttf
      fira-code
      fira-code-symbols
      dina-font
      proggyfonts
      joypixels
      (nerdfonts.override { fonts = [ "FiraCode" "FiraMono" ]; })
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
