{ config, lib, pkgs, ... }:
let
  x="x";
in {
options.roles.janWorkstation = {
  enable = lib.mkEnableOption "Common config for my workstations";
};
config = lib.mkIf config.roles.janWorkstation.enable {

  # programs.mtr.enable = true;

  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  #   pinentryFalovr = tty;
  # };

  environment.systemPackages = with pkgs; [
    # Workstation
    yadm gopass pinentry
    mkpasswd zip trash-cli
    st kitty xonsh
    oathToolkit qrencode
    # network
    inetutils dnsutils nmap mtr openssl sshpass nload

    # Multimedia
    ncmpcpp ffmpeg-full
    deluge
  ];

}; }

