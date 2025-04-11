{ config
, lib
, pkgs
, ...
}:
let
  hashedPasswordFile = "/etc/secrets/users/roomies/pw";
in
{
  users.users.roomies = {
    isNormalUser = true;
    inherit hashedPasswordFile;
    extraGroups = [
      "audio"
      "networkmanager"
      "video"
    ];
    openssh.authorizedKeys.keys = [ ];
  };

  veil.secrets.roomiespw = {
    script = "gopass show -o Infrastructure/roomiespw | mkpasswd --method=SHA-512 --stdin";
    target = hashedPasswordFile;
  };
}
