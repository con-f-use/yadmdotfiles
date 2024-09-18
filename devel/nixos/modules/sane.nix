{ config, lib, ... }:
{
  documentation = {
    enable = lib.mkDefault true;
    man.enable = lib.mkDefault true;
    doc.enable = lib.mkForce false;  # install stuff in <store-path>/share/docs
    nixos.enable = lib.mkForce false; # Takes too much time and are not cached
    info.enable = lib.mkForce false;
  };

  # i18n.defaultLocale = "en_DK.UTF-8"; # https://unix.stackexchange.com/questions/62316/why-is-there-no-euro-english-locale
  time.timeZone = lib.mkDefault "UTC";

  nix.daemonCPUSchedPolicy = lib.mkDefault "batch";
  nix.daemonIOSchedClass = lib.mkDefault "idle";
  nix.daemonIOSchedPriority = lib.mkDefault 7;

  security.rtkit.enable = config.services.pipewire.enable;

  security.sudo.extraConfig = ''
    Defaults pwfeedback
    Defaults passprompt="[31m sudo: password for %p@%h, running as %U:[0m "
  '';

  services.pipewire = {
    enable = config.services.xserver.enable;
    pulse.enable = true;
    alsa.enable = true;
  };

  networking.hostId = lib.mkDefault (builtins.substring 0 8 (builtins.hashString "md5" config.networking.hostName));
}
