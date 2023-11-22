{ config, lib, pkgs, inputs, nixrepo, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    ../modules
    ../users
  ] ++ (lib.optional (builtins.pathExists ./cachix.nix) ./cachix.nix);

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
    };
  };
  swapDevices = [ ];

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";
  # Use the extlinux boot loader. (NixOS wants to enable GRUB by default)
  boot.loader.grub.enable = false;
  # Enables the generation of /boot/extlinux/extlinux.conf
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_rpi4;
  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];
  # ttyAMA0 is the serial console broken out to the GPIO
  boot.kernelParams = [
    "8250.nr_uarts=1" # may be required only when using u-boot
    "console=ttyAMA0,115200"
    "console=tty1"
  ];

  # Required for the Wireless firmware
  hardware.enableRedistributableFirmware = true;

  # RASPBERRY PI 4 B
  # without GPU:
  services.xserver = {
    enable = true;
    displayManager.lightdm.enable = true;
    videoDrivers = [ "fbdev" ];
  };
  # GPU enabled:
  #hardware.opengl = {
  #  enable = true;
  #  setLdLibraryPath = true;
  #  package = pkgs.mesa_drivers;
  #};
  #hardware.deviceTree = {
  #  kernelPackage = pkgs.linux_rpi4;
  #  overlays = [ "${pkgs.device-tree_rpi.overlays}/vc4-fkms-v3d.dtbo" ];
  #};
  #services.xserver = {
  #  enable = true;
  #  displayManager.lightdm.enable = true;
  #  videoDrivers = [ "modesetting" ];
  #};
  #boot.loader.raspberryPi.firmwareConfig = ''
  #  gpu_mem=192
  #'';
  # END RASPBERRY PI 4 B


  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  time.timeZone = "Europe/Vienna";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  networking.interfaces.wlan0.useDHCP = false;

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };
  users.groups.gpio = { };
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="intel_backlight", MODE="0666", RUN+="${pkgs.coreutils}/bin/chmod a+w /sys/class/backlight/%k/brightness"
    SUBSYSTEM=="bcm2835-gpiomem", KERNEL=="gpiomem", GROUP="gpio",MODE="0660"
    SUBSYSTEM=="gpio", KERNEL=="gpiochip*", ACTION=="add", RUN+="${pkgs.bash}/bin/bash -c 'chown root:gpio  /sys/class/gpio/export /sys/class/gpio/unexport ; chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport'"
    SUBSYSTEM=="gpio", KERNEL=="gpio*", ACTION=="add",RUN+="${pkgs.bash}/bin/bash -c 'chown root:gpio /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value ; chmod 660 /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value'"
  '';
  programs.slock.enable = true;
  services.clipmenu.enable = true;
  services.xserver.exportConfiguration = true;
  #services.dconf.enable = true;
  services.gvfs.enable = true;
  services.xserver.displayManager = {
    defaultSession = "none+instantwm";
    #startx.enable = true;
    gdm.enable = false;
    sddm.enable = false;
  };
  services.xserver.desktopManager = {
    gnome.enable = false;
    plasma5.enable = false;
    xterm.enable = false;
  };
  services.xserver.windowManager = {
    session = pkgs.lib.singleton {
      name = "instantwm";
      start = ''
        startinstantos &
        waitPID=$!
      '';
    };
  };
  fonts.fonts = with pkgs; [
    cantarell-fonts
    fira-code
    fira-code-symbols
    dina-font
    joypixels
    (pkgs.python3.withPackages (ps: with ps; [
      setuptools
      virtualenv
      requests
      beautifulsoup4
      pygls
    ]))
    (nerdfonts.override { fonts = [ "FiraCode" "FiraMono" ]; })
  ];
  nixpkgs.config.joypixels.acceptLicense = true;
  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-linux";


  # Shell Convenience
  environment.shellAliases = { ll = "ls -al --color=auto"; ff = "sudo vi /etc/nixos/configuration.nix"; ss = "sudo nixos-rebuild switch"; };
  environment.homeBinInPath = true;
  environment.etc."gitconfig".text = ''
    [user]
    name = con-f-use
    email = con-f-use@gmx.net
    signingkey = 2C726AD9
    [alias]
    ci = commit
    co = checkout
    st = status
    d = diff
    lg = log
    fa = fetch --all
  '';
  environment.etc."inputrc".text = ''
    "\e[Z": menu-complete
    "\e\e[C": forward-word
    "\e\e[D": backward-word
    "\e[A": history-search-backward
    "\e[B": history-search-forward
  '';

  # Packages
  environment.systemPackages = with pkgs; [
    htop
    gnupg
    screen
    tree
    file
    fasd
    fzf
    direnv
    wget
    curl
    w3m
    inetutils
    dnsutils
    nmap
    openssl
    mkpasswd
    flameshot
    gitAndTools.git
    git-lfs
    nix-prefetch-scripts
    nix-update
    nixpkgs-review
    cachix
    vim
    papirus-icon-theme
    arc-theme
    (python3.withPackages (ps: with ps; [
      setuptools
      wheel
      appdirs
      virtualenv
      requests
      beautifulsoup4
      pygls
    ]))
    black
  ];

  # Porkbun update
  systemd.services.porkbun_ddns = {
    serviceConfig.Type = "oneshot";
    #path = [ pgks.bash ];
    script =
      let
        porkbun = pkgs.writers.writePython3Bin "porkbun-ddns" { libraries = [ pkgs.python3Packages.requests ]; flakeIgnore = [ "E" "F" "W" ]; } (builtins.readFile ./porkbun-ddns.py);
      in
      ''
        ${porkbun}/bin/porkbun-ddns
        ${porkbun}/bin/porkbun-ddns -4 || true
      '';
  };
  systemd.timers.porkbun_ddns = {
    wantedBy = [ "timers.target" ];
    partOf = [ "porkbun_ddns.service" ];
    timerConfig.OnCalendar = [ "*-*-* *:00:00" ]; # hourly
  };

  # SSH
  services.openssh.enable = true;

  # Firewall
  networking.firewall.allowedTCPPorts = [ 60022 60043 60080 ];
  #networking.firewall.allowedUDPPorts = [ ... ];
  #networking.firewall.enable = false;

  # Nix
  nix.autoOptimiseStore = true;
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 14d";
  };
  system.stateVersion = "21.03"; # It‘s perfectly fine and recommended to leave this value at the release version of the first install of this system.
}

