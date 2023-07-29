{ config, lib, pkgs, ... }:
let
  kitty-xterm-link = pkgs.writeScriptBin "xterm" "${pkgs.kitty}/bin/kitty \"$@\"";
in
{
  options.roles.workstation = {
    enable = lib.mkEnableOption "Common config for my workstations";
  };
  config = lib.mkIf config.roles.workstation.enable {

    # programs.mtr.enable = true;

    # programs.gnupg.agent = {
    #   enable = true;
    #   enableSSHSupport = true;
    #   pinentryFalvor = "tty";  # "curses" "gtk2" "gnome3" "qt"
    # };
    #services.dbus.packages = [ pkgs.gcr ];
    #services.pcscd.enable = true;
    # pkill -f gpg-agent; pkill -f pinentry
    # systemctl --user restart gpg-agent.socket gpg-agent-extra.socket gpg-agent-ssh.socket
    # systemctl --user restart gpg-agent
    # gpgconf --reload gpg-agent

    environment.systemPackages = with pkgs; [
      # Workstation
      yadm
      gopass
      gopass-jsonapi
      pinentry
      pinentry-curses
      pinentry-gtk2
      mkpasswd
      zip
      trash-cli
      st
      # kitty kitty-xterm-link
      xonsh
      oathToolkit
      qrencode
      # network
      inetutils
      dnsutils
      nmap
      mtr
      openssl
      sshpass
      nload

      # Multimedia
      ncmpcpp
      ffmpeg-full
      deluge
    ];

  };
}

