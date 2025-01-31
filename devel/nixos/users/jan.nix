{
  config,
  lib,
  pkgs,
  ...
}:
let
  hashedPasswordFile = "/etc/secrets/janpw";

  pub_keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKnSKUwKbbqQ6x5E5q2aJVWRhTfkH7ovTls6WnkQFnPD confus@confusion"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKApw5HSv9hL9FbH2+aRLJZnTbr3PlCsMmccaWT4BVRbAAAACXNzaDpDLWJpbw== ssh:C-bio"
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIFLX8PVoahKNhOkA4+J2nxlUKf+JDdndkvt8C6AIvzJGAAAAEHNzaDpiYWNrdXBfQy1ORkM= ssh:backup_C-NFC"
  ];

  extraGroups = [
    "adm"
    "audio"
    "dialout"
    "disk"
    "docker"
    "fuse" # sshfs
    "gpio"
    "input" # libinput-gestures
    "libvirtd"
    "networkmanager"
    "nm-openvpn"
    "plugdev"
    "vboxuser"
    "video"
    "wheel"
    "wireshark"
    config.services.kubo.group
  ];
in
{
  #users.groups.jan = { gid = 1000; };
  users.users."jan" = {
    isNormalUser = true;
    uid = 1000;
    #openssh.authorizedKeys.keys = ssh_pkeys;
    inherit hashedPasswordFile extraGroups;
    openssh.authorizedKeys.keys = pub_keys;
  };

  users.users."naj" = {
    isNormalUser = true;
    uid = 1001;
    #gid = 1000;
    inherit extraGroups;
    hashedPassword = "$6$8Eq5KFCjQWpctZFH$nw58OuniWrj2KyTijYDpydoDoQ2oijCFbzSHFXZPry46MOww8/8sdorIwJ4d5kmxyf1zdiPi4xbojNb63eLGj0";
    openssh.authorizedKeys.keys = pub_keys;
  };

  veil.secrets.janpw = {
    target = hashedPasswordFile;
    script = "gopass show -o Infrastructure/janpw | mkpasswd --method=SHA-512 --stdin";
  };
}
