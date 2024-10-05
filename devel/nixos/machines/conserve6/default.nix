{
  self,
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./filesystem.nix
    ./boot.nix
    ./system.nix
    ./networking.nix
    ./gnome.nix
    ./locale.nix
    ./arr.nix
    ../../users/roomies.nix
    ./vcs.nix
    { options.programs.gnupg.agent.pinentryPackage = lib.mkOption { type = lib.types.package; }; } # ToDo: remove this when cnsrv not needed
  ];
  roles = {
    essentials = {
      enable = true;
      main_user = config.users.users.jan.name;
    };
    bashbling.enable = true;
    dev.enable = true;
  };
  users.groups.conserve.members = [
    config.users.users.jan.name
    config.users.users.roomies.name
  ];

  environment.systemPackages = import ./packages.nix pkgs;

  #programs.gnupg.agent.pinentryFlavor = "gtk2"; # ToDo: remove this when cnsrv not needed
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
