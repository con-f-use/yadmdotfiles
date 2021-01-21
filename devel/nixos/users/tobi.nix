{ config, lib, pkgs, secrets, ... }:

rec {
  #users.groups.tobi = { gid = 1000; };
  users.users.tobi = {
    isNormalUser = true;
    #uid = 1000;
    group = "tobi";
    extraGroups = [ "users" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGn4tzEYCRyYY2zEn+3wjoaBkcHo43ISoSz2r9fOoCdO"
    ];
  };
  users.users.root.openssh.authorizedKeys.keys = users.users.tobi.openssh.authorizedKeys.keys;
}

