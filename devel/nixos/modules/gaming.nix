{ config, lib, pkgs, ... }:
{

  options.my.roles.gaming-client = {
    enable = lib.mkEnableOption "Gaming client";
  };

  config = lib.mkIf config.my.roles.gaming-client.enable {
    # hardware.opengl.driSupport32Bit = true;
    hardware.pulseaudio.support32Bit = true;

    # Firewall ports used by Steam in-home streaming.
    networking.firewall.allowedTCPPorts = [ 27036 27037 ];
    networking.firewall.allowedUDPPorts = [ 27031 27036 ];

    environment.systemPackages = with pkgs; [
      steam
      xorg.libxcb #chiaki
    ];
  };
}

