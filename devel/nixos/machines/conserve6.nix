{ self, config, lib, pkgs, ... }:

{
  boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  system.stateVersion = "23.05"; # Do not edit this ever!

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/a0adcaeb-895d-4038-9f74-c890c12e2ca3";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/41B6-51F6";
    fsType = "vfat";
  };

  swapDevices = [ ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s13f0u4u3c2.useDHCP = lib.mkDefault true;

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.enableAllFirmware = true;
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.zfs.forceImportRoot = false;
  # boot.supportedFilesystems = [ "ntfs" "zfs" "btrfs" ];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.supportedFilesystems = [ "ntfs" "btrfs" ];

  networking.hostName = "conserve6"; # Define your hostname.
  networking.hostId = "7ca45f2c"; # head -c 8 /etc/machine-id  # system (used by zfs)
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Vienna";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_DK.UTF-8";
    LC_IDENTIFICATION = "en_DK.UTF-8";
    LC_MEASUREMENT = "en_DK.UTF-8";
    LC_MONETARY = "en_DK.UTF-8";
    LC_NAME = "en_DK.UTF-8";
    LC_NUMERIC = "en_DK.UTF-8";
    LC_PAPER = "en_DK.UTF-8";
    LC_TELEPHONE = "en_DK.UTF-8";
    LC_TIME = "en_DK.UTF-8";
  };
  console.keyMap = "us-acentos";

  services.xserver = {
    enable = true;
    layout = "us";
    xkbVariant = "intl";
    libinput.enable = true;
    updateDbusEnvironment = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };
  services.gnome = {
    gnome-browser-connector.enable = true;
    core-shell.enable = true;
    #gnome-remote-desktop = enable;
  };

  services.printing.enable = false;
  security.rtkit.enable = true;
  services.fwupd.enable = true;

  #sound.enable = true;
  hardware.pulseaudio = {
    # enable = true;
    enable = false;
    package = pkgs.pulseaudioFull; # 'full' instead of 'light' for e.g. bluetooth
    support32Bit = true;
    configFile = pkgs.runCommand "default.pa" { } ''
      sed 's/module-udev-detect$/module-udev-detect tsched=0/' \
          ${pkgs.pulseaudioFull}/etc/pulse/default.pa > $out
    '';
    daemon.config = {
      flat-volumes = "no";
      enable-lfe-remixing = "yes";
      remixing-produce-lfe = "yes";
      remixing-consume-lfe = "yes";
      default-channel-map = "front-left,front-right,rear-left,rear-right,front-center,lfe";
      #default-sample-rate = 48000;
      avoid-resampling = "yes";
      # in /etc/pulse/default.pa: load-module module-udev-detect tsched=0
      # /etc/modprobe.d/sound.conf
      # options snd-hda-intel vid=8086 pid=8ca0 snoop=0
      default-sample-channels = 6;
    };
  };
  # hardware.bluetooth.enable = true;

  services.pipewire = {
    # enable = lib.mkForce false;
    enable = true;
    audio.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
    # systemWide = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.mutableUsers = false;
  users.users.jan = {
    isNormalUser = true;
    description = "jan";
    extraGroups = [ "pulse" "pulseaudio" "pulse" "puse-user" "networkmanager" "wheel" "pipewire" "users" "kvm" "input" "gdm" "adm" "video" "dailout" "disk" "tape" "cdrom" "floppy" "audio" "lp" "messgebus" "kmem" ];
    hashedPassword = "$6$Xe3WNdmP$JqMUSRF3j6ytfCz7ceT1pI4Gw05FLy3n5UxkjSpQ7cilxcH/WoN8g2lOoVskJKoIDsadH9OiwHEaAUYZQXze7.";
  };
  users.users.naj = {
    isNormalUser = true;
    description = "naj";
    extraGroups = [ "pulse" "pulseaudio" "networkmanager" "wheel" "pipewire" "users" "kvm" "input" "gdm" "adm" "video" "dailout" "disk" "tape" "cdrom" "floppy" "audio" "lp" "messgebus" "kmem" ];
    hashedPassword = "$6$Xe3WNdmP$JqMUSRF3j6ytfCz7ceT1pI4Gw05FLy3n5UxkjSpQ7cilxcH/WoN8g2lOoVskJKoIDsadH9OiwHEaAUYZQXze7.";
  };

  nixpkgs.config.allowUnfree = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = true;
    };
  };

  environment.homeBinInPath = true;

  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_BIN_HOME = "\${HOME}/.local/bin";
    XDG_DATA_HOME = "\${HOME}/.local/share";
    XDG_STATE_HOME = "\${HOME}/.local/state";

    PATH = [ "\${XDG_BIN_HOME}" ];
  };

  environment.etc."inputrc".text = ''
    "\e[Z": menu-complete
    "\e\e[C": forward-word
    "\e\e[D": backward-word
    "\e[A": history-search-backward
    "\e[B": history-search-forward
  '';

  environment.enableAllTerminfo = true;

  environment.shellAliases = {
    ff = "sudo vi /etc/nixos/configuration.nix";
    ss = ''echo 'Set a label: -p <label>'; [ -n "$(sudo git -C /etc/nixos status --porcelain=v1 2>/dev/null)" ] && sudo git -C /etc/nixos add -A && git status && git -C /etc/nixos commit -m 'alias switch' && sudo nixos-rebuild switch && git -C /etc/nixos tag -a -m 'alias switch' "$(readlink -f /run/current-system/ | cut -d'-' -f 5)"'';
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
    config = {
      alias = {
        ci = "commit";
        co = "checkout";
        st = "status";
        d = "diff";
        dc = "diff --cached";
        l = "log";
        lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cD) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    firefox
    ffmpeg
    fribidi
    magic-wormhole
    pciutils
    x264
    pavucontrol
    mpv
    alsa-utils
    gparted
  ];

}
