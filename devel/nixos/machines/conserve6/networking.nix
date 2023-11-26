{ config, ... }:
{
  networking = {
    hostName = "conserve6";
    hostId = "7ca45f2c"; # head -c 8 /etc/machine-id  # system (used by zfs)
    interfaces.enp0s13f0u4u3c2.useDHCP = true; # anker mini dongle
    interfaces.enp0s13f0u3.useDHCP = true; # framework adapter module
    networkmanager.enable = true;
  };

  users.users.root.openssh.authorizedKeys.keys = config.users.users.jan.openssh.authorizedKeys.keys;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
      X11Forwarding = true;
    };
  };
}
