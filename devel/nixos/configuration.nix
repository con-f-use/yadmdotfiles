{ config, lib, pkgs, ...}:
let

  main_user = "jan";

  passhash = "$6$Xe3WNdmP$JqMUSRF3j6ytfCz7ceT1pI4Gw05FLy3n5UxkjSpQ7cilxcH/WoN8g2lOoVskJKoIDsadH9OiwHEaAUYZQXze7.";

in {
  imports = [
    ./this.nix  # symlink to machine profile
    ./modules/default.nix
  ] ++ (lib.optional (builtins.pathExists ./cachix.nix) ./cachix.nix);

  #console.font = "latarcyrheb-sun32";  # larger bootmode fonts
  #boot.loader.systemd-boot.consoleMode = lib.mkDefault "max";
  #hardware.video.hidpi.enable = true;

  roles.janZfs.enable = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "conix";
  #networking.wireless.enable = true;

  networking.useDHCP = false;
  networking.networkmanager.enable = true;
  programs.nm-applet.enable = true;

  #security.wrappers = { slock.source = "${pkgs.slock.out}/bin/slock"; };
  time.timeZone = "Europe/Vienna";

  hardware.opengl.driSupport32Bit = true;
  #hardware.opengl.extraPackages = [ pkgs.intel-ocl ];
  #hardware.bluetooth.enable = true;
  #services.blueman.enable = true;
  #services.tor = { enable = true; client.enable = true; };
  #services.lorri.enable = true;

  documentation.nixos.enable = false;

  users.mutableUsers = false;
  users.users.root.hashedPassword = "*";
  users.users."${main_user}" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "networkmanager" "wireshark" "dialout" "plugdev" "adm" "disk" "video" "docker" ];
    #openssh.authorizedKeys.keys = ssh_pkeys;
    hashedPassword = passhash;
  };
  users.users."naj" = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "networkmanager" "wireshark" "dialout" "plugdev" "adm" "disk" "video" "docker" ];
    #openssh.authorizedKeys.keys = ssh_pkeys;
    hashedPassword = passhash;
  };

  roles.cudawork.enable = true;
  roles.janEssential = { enable = true; main_user = main_user; };
  roles.janDev.enable = true;
  roles.janX.enable = true;
  roles.janWorkstation.enable = true;
  environment.systemPackages = with pkgs; [
    htop
    # Gaming
    #steam xorg.libxcb
  ];

  nixpkgs.config.allowUnfree = true;  # allowUnfreePredicate for individual packages
  system.stateVersion = "20.09";
}

