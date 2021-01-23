{ config, lib, pkgs, ... }:
let
  kitty-xterm-link = pkgs.writeScriptBin "xterm" "${pkgs.kitty}/bin/kitty \"$@\"";
in {
options.roles.workstation = {
  enable = lib.mkEnableOption "Common config for my workstations";
};
config = lib.mkIf config.roles.workstation.enable {

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
    st kitty kitty-xterm-link xonsh
    oathToolkit qrencode
    # network
    inetutils dnsutils nmap mtr openssl sshpass nload

    # Multimedia
    ncmpcpp ffmpeg-full
    deluge
  ];

}; }

