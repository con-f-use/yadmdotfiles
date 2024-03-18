{ config, lib, pkgs, ... }:
let
  hashedPasswordFile = builtins.trace "reminder: provision hashed password file!" "/etc/secrets/janpw";
  pub_keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6lLuZxKu3u3/yTpcSlfa+NZZGDywrvqwX2IhSn36BNFMMShQF/MX1Kuy5txEHDfhOgj8omBWV9X03N8vlmy3Hh9T0uZe6earw3VOU37hcHEhh0YdV+boWdD4lCllRZ1o0HtsoFqVBg4gHAIsMjBN0/eC2qfN6T1/8/Hlvqspjx/ZgQF34PkEA7r7nFvUOAh3E72AYNiScsd1SXTq5hMhUsEs9g4EMO5MYWft7ybsysoBcnJcE+oEnsKtbsIdVUBXGWGqBz+Q7FbhPLsJECJ4nhuxh6SPfemvDZ2r94s3/mykl1X7OTj1bKCgtigCY/UFBk9KHDZ1XCKTaE4xXHg5oEo8glx2g+cj4OwqdpNt1A8QTiITi44KOeojFQAYK6r1RN0hArHHXAT1H7j/ha5x4C05B4Jb7JaMHGk5kEqqm3QxKh3K4nrshBa3BBhBI8Gozw3oe+bzX5EXUXVzJyOKO6xMqF+MATOd5lPVzDRgxbsERPVz4JXFgo89S/QPhTRfSGeN77h42ZK7mj3eUC8z/F/2d60jJHRR75m6aoFC39oX2WHgvlvAhRVLWYh17ZxEjVxTIRkcUKO+uPUnY3l6Qp1B3bRQ38w695JLt7c9k2xSOVCkJW8R+WGqnFzO/vcGNbU8k9HkBSv0exk0+aPHkkp820iu5+DVzRvh6jtmoww== confus@confusion-2016-07-30"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKnSKUwKbbqQ6x5E5q2aJVWRhTfkH7ovTls6WnkQFnPD confus@confusion"
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
    inherit hashedPasswordFile extraGroups;
    openssh.authorizedKeys.keys = pub_keys;
  };
}
