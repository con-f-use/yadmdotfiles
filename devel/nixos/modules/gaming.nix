{
  config,
  lib,
  pkgs,
  ...
}:
{

  options.my.roles.gaming-client = {
    enable = lib.mkEnableOption "Gaming client";
  };

  config = lib.mkIf config.my.roles.gaming-client.enable {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    environment.systemPackages = with pkgs; [
      xorg.libxcb # chiaki
    ];
  };
}
