{ self, config, lib, pkgs, ... }:

{
  roles = {
    essentials = {
      enable = true;
      main_user = config.users.users.jan.name;
    };
    dev.enable = true;
  };

  # boot.initrd.availableKernelModules = [ "xhci_pci" "thunderbolt" "nvme" "usb_storage" "usbhid" "sd_mod" ];
  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "thunderbolt" "nvme" "usb_storage" "usbnet" "usbhid" "sd_mod" "e1000e" "r8169" "r8152" "cdc_ncm" ];
  #boot.initrd.kernelModules = [ ];
  boot.initrd.kernelModules = [ "xhci_pci" "cdc_ncm" "usbnet" "thunderbolt" "nvme" "usb_storage" "usbhid" "sd_mod" "r8152" "dm-snapshot" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.initrd.preLVMCommands = lib.mkOrder 400 "sleep 5";  # wait for interfaces
  boot.initrd.network = {
    # For initrd networking, you should add the module(s) required for your network card to
    #boot.initrd.availableKernelModules. lspci -v | grep -iA8 'network\|ethernet'
    enable = true;
    ssh.enable = true;
    ssh.port = 3022;
    ssh.authorizedKeys = config.users.users.jan.openssh.authorizedKeys.keys;
  };
  boot.initrd.network.ssh.hostKeys = [ "/etc/secrets/initrd/ssh_host_rsa_key" "/etc/secrets/initrd/ssh_host_ed25519_key" ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/dedcd975-a6f5-4583-8420-1c39d6a6183a";
    fsType = "ext4";
  };

  boot.initrd.luks.reusePassphrases = true;
  boot.initrd.luks.devices."conserve6".device = "/dev/disk/by-uuid/a8afd5ea-d5d9-4c21-aed8-44da7efdfd4a";
  boot.initrd.luks.forceLuksSupportInInitrd = true;

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/67B4-DC3C";
    fsType = "vfat";
  };

  swapDevices = [ { device = "/swapfile"; size = 33000; } ];

  #networking.useDHCP = lib.mkDefault false;
  networking.interfaces.enp0s13f0u4u3c2.useDHCP = true;  # anker mini dongle
  # networking.interfaces.enp0s13f0u3.useDHCP = true;  # framework adapter module

  system.stateVersion = "23.05"; # Do not edit this ever!
  nixpkgs.hostPlatform = "x86_64-linux";
  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = true;

  users.users.root.openssh.authorizedKeys.keys = config.users.users.jan.openssh.authorizedKeys.keys;

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

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
      X11Forwarding = true;
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

# Bus 002 Device 003: ID 0bda:8156 Realtek Semiconductor Corp. USB 10/100/1G/2.5G LAN
# description: Ethernet interface
# product: USB 10/100/1G/2.5G LAN
# physical id: a
# bus info: usb@2:3
# logical name: enp0s13f0u3
# serial: 9c:bf:0d:00:06:7b
# size: 1Gbit/s
# capacity: 2500Mbit/s
# capabilities: ethernet physical tp mii 10bt 10bt-fd 100bt 100bt-fd 1000bt 1000bt-fd 2500bt-fd autonegotiation
# configuration: autonegotiation=on broadcast=yes driver=r8152 driverversion=v1.12.13 duplex=full firmware=rtl8156b-2 v3 10/20/23 ip=192.168.1.17 link=yes multicast=yes port=MII speed=1Gbit/s
#
# Bus 002 Device 004: ID 0b95:1790 ASIX Electronics Corp. AX88179 Gigabit Ethernet
# description: Ethernet interface
# product: AX88179A
# physical id: b
# bus info: usb@2:4.3
# logical name: enp0s13f0u4u3c2
# serial: f8:e4:3b:40:b7:01
# capabilities: ethernet physical
# configuration: autonegotiation=off broadcast=yes driver=cdc_ncm driverversion=6.6.1 duplex=half firmware=CDC NCM (NO ZLP) link=no multicast=yes port=twisted pair
