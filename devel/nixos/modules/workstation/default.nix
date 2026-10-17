{
  config,
  lib,
  pkgs,
  ...
}:
let
  kitty-xterm-link = pkgs.writeScriptBin "xterm" "${pkgs.kitty}/bin/kitty \"$@\"";
in
{
  options.roles.workstation = {
    enable = lib.mkEnableOption "Common config for my workstations";
  };
  config = lib.mkIf config.roles.workstation.enable {

    # programs.mtr.enable = true;

    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      # pinentryFlavor = "gtk2"; # "curses" "tty" "gnome3" "qt"
      pinentryPackage = pkgs.pinentry-gtk2; # new from 30.03.2024 on
    };
    #services.dbus.packages = [ pkgs.gcr ];
    #services.pcscd.enable = true;
    # pkill -f gpg-agent; pkill -f pinentry
    # systemctl --user restart gpg-agent.socket gpg-agent-extra.socket gpg-agent-ssh.socket
    # systemctl --user restart gpg-agent
    # gpgconf --reload gpg-agent

    programs.xonsh = {
      enable = true;
      #config = '' '';
    };

    environment.systemPackages = with pkgs; [
      conservetool

      # Workstation
      yadm
      gopass
      gopass-jsonapi
      pinentry-curses
      pinentry-gtk2
      mkpasswd
      zip
      trash-cli
      st
      kitty
      oath-toolkit
      qrencode
      ripgrep
      usbutils
      lshw
      lua
      wl-clipboard
      # wl-clipboard-rs # breaks helix, see https://github.com/YaLTeR/wl-clipboard-rs/issues/8
      zoxide

      # Network
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
